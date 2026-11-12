"""Populate the geoblock ipsets from the db-ip country-lite database.

Cache-first: unless the live sets already hold it, the last good copy is
loaded before the network is touched, so a boot or a firewall restart
repopulates without waiting on a fetch, and a failed or truncated download
leaves the previous data in place rather than installing an allowlist that
admits nobody.

Exit 0 when the sets are current, 2 when a refresh failed but the cache is
served, 1 when nothing could be served.
"""

import argparse
import csv
import gzip
import hashlib
import io
import ipaddress
import os
import subprocess
import sys
import urllib.error
import urllib.request
from datetime import date
from pathlib import Path

URL = "https://download.db-ip.com/free/dbip-country-lite-{month}.csv.gz"

# Cloudflare fronts the download and refuses urllib's default agent.
USER_AGENT = "nix-config-geoblock/1"

CACHE_PREFIX, CACHE_SUFFIX = "dbip-country-lite-", ".csv.gz"

FAMILIES = {4: "inet", 6: "inet6"}

SERVED_STALE = 2


def months():
    """The current month, then the previous one.

    The URL is month-stamped and the new file appears a few days into the
    month, so the previous one is the only sane fallback.
    """
    today = date.today()
    previous = (today.replace(day=1) - date.resolution).replace(day=1)
    return [today.strftime("%Y-%m"), previous.strftime("%Y-%m")]


def cached(state):
    """The newest cached release and its month."""
    releases = sorted(state.glob(f"{CACHE_PREFIX}*{CACHE_SUFFIX}"))
    if not releases:
        return None, None
    cache = releases[-1]
    return cache, cache.name.removeprefix(CACHE_PREFIX).removesuffix(CACHE_SUFFIX)


def store(state, month, data):
    cache = state / f"{CACHE_PREFIX}{month}{CACHE_SUFFIX}"
    staged = state / f".{cache.name}.tmp"
    staged.write_bytes(data)
    os.replace(staged, cache)
    for old in state.glob(f"{CACHE_PREFIX}*{CACHE_SUFFIX}"):
        if old != cache:
            old.unlink()


def fetch(newer_than):
    """The newest release after newer_than as (month, data), or None.

    A published month never changes, so nothing is downloaded while the cache
    is current. Only a 404 falls back a month; any other error is a failed
    refresh.
    """
    for month in months():
        if newer_than and month <= newer_than:
            return None
        request = urllib.request.Request(
            URL.format(month=month), headers={"User-Agent": USER_AGENT}
        )
        try:
            with urllib.request.urlopen(request, timeout=120) as response:
                return month, response.read()
        except urllib.error.HTTPError as error:
            if error.code != 404:
                raise
    raise RuntimeError(f"no db-ip release published for {months()}")


def prefixes(data, countries):
    """Collapsed CIDRs per address family for the wanted countries.

    db-ip ships arbitrary start/end ranges, which have to be split into CIDRs
    to be ipset elements.
    """
    found = {4: [], 6: []}
    with gzip.open(io.BytesIO(data), "rt", newline="") as handle:
        for row in csv.reader(handle):
            if len(row) != 3 or row[2].lower() not in countries:
                continue
            start, end = (
                ipaddress.ip_address(row[0]),
                ipaddress.ip_address(row[1]),
            )
            found[start.version].extend(ipaddress.summarize_address_range(start, end))
    return {
        version: list(ipaddress.collapse_addresses(nets))
        for version, nets in found.items()
    }


def check(candidate, live, minimum, max_elem):
    """Reject a dataset that is implausibly short or cannot be installed.

    A truncated fetch that installs an empty or decimated allowlist is a total
    outage and the one failure here that cannot recover on its own, so a
    shrinking dataset is treated as corruption rather than as news.
    """
    total = sum(len(nets) for nets in candidate.values())
    if total < minimum:
        raise RuntimeError(f"only {total} prefixes, expected at least {minimum}")
    for version, nets in candidate.items():
        if len(nets) > max_elem:
            raise RuntimeError(f"v{version} has {len(nets)} prefixes, over {max_elem}")
        was = live[version]
        if was and len(nets) < was // 2:
            raise RuntimeError(f"v{version} prefixes fell from {was} to {len(nets)}")


def ipset(*args, stdin=None, check=True):
    subprocess.run(
        ["ipset", *args],
        input=stdin,
        text=True,
        check=check,
        stderr=None if check else subprocess.DEVNULL,
    )


def entries(sets):
    """Live element count per family; a missing set counts as empty."""
    counts = {}
    for version, name in sets.items():
        listing = subprocess.run(
            ["ipset", "list", "-t", name], capture_output=True, text=True
        ).stdout
        counts[version] = next(
            (
                int(line.split(":")[1])
                for line in listing.splitlines()
                if line.startswith("Number of entries:")
            ),
            0,
        )
    return counts


def install(sets, max_elem, found):
    """Swap every family's set in, or none of them.

    Each live set is built under a scratch name and exchanged, so a
    half-populated set is never consulted, and all scratch sets are built
    before the first swap, so a failed restore leaves the families in step.
    The live parameters are never compared against, so a changed maxelem
    arrives through the swap rather than as a create conflict.
    """
    scratch = {version: f"{name}-new" for version, name in sets.items()}
    try:
        for version, name in scratch.items():
            ipset("destroy", name, check=False)
            header = f"hash:net family {FAMILIES[version]} maxelem {max_elem}"
            ipset(
                "restore",
                stdin="".join(
                    [f"create {name} {header}\n"]
                    + [f"add {name} {net}\n" for net in found[version]]
                ),
            )
        for version, live in sets.items():
            ipset("create", live, "hash:net", "family", FAMILIES[version], check=False)
            ipset("swap", scratch[version], live)
            print(f"{live}: {len(found[version])} prefixes", file=sys.stderr)
    finally:
        for name in scratch.values():
            ipset("destroy", name, check=False)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--v4-set", required=True)
    parser.add_argument("--v6-set", required=True)
    parser.add_argument("--max-elem", type=int, required=True)
    parser.add_argument("--min-prefixes", type=int, default=256)
    parser.add_argument("countries", nargs="+")
    args = parser.parse_args()

    state = Path(os.environ["STATE_DIRECTORY"])
    sets = {4: args.v4_set, 6: args.v6_set}
    countries = {country.lower() for country in args.countries}
    # Identifies what the live sets were built from. It lives on tmpfs, so it
    # dies with the sets on reboot; the emptiness check covers sets lost
    # without one.
    marker = Path(os.environ["RUNTIME_DIRECTORY"]) / "installed"
    config = repr((sorted(countries), args.max_elem, sorted(sets.items())))

    def fingerprint(data):
        return hashlib.sha256(data + config.encode()).hexdigest()

    live = entries(sets)
    cache, cached_month = cached(state)
    if cache:
        data = cache.read_bytes()
        if (
            not all(live.values())
            or not marker.exists()
            or marker.read_text() != fingerprint(data)
        ):
            try:
                found = prefixes(data, countries)
            except Exception as error:
                print(f"discarding unreadable cache: {error}", file=sys.stderr)
                cache.unlink()
                cache = cached_month = None
            else:
                check(found, {4: 0, 6: 0}, args.min_prefixes, args.max_elem)
                install(sets, args.max_elem, found)
                marker.write_text(fingerprint(data))
                live = {version: len(nets) for version, nets in found.items()}

    try:
        release = fetch(cached_month)
        if release is None:
            print(f"db-ip {cached_month} is current", file=sys.stderr)
            return 0
        month, data = release
        candidate = prefixes(data, countries)
        check(candidate, live, args.min_prefixes, args.max_elem)
        install(sets, args.max_elem, candidate)
    except Exception as error:
        print(f"refresh failed: {error}", file=sys.stderr)
        return SERVED_STALE if cache else 1
    store(state, month, data)
    marker.write_text(fingerprint(data))
    print(f"refreshed from db-ip {month}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
