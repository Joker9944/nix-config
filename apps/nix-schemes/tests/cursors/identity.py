#!/usr/bin/env python3
"""Assert the vendored templates still render as the Breeze they were annotated
from.

A template keeps upstream's literal paint and records the slot beside it, so it
renders standalone and is directly comparable to its source. That makes this a
real gate rather than a self-consistency check: a paint annotated with the
wrong slot, a hand-edit, and an upstream bump the vendoring app has not been
re-run against all show up here, and none of them would show up in a rendered
theme anyone was looking at.

Usage: identity.py <upstream-svg-dir> <template-svg-dir>
"""

import pathlib
import subprocess
import sys
import tempfile

SIZE = 128


def render(directory, name, into):
    png = into / name.replace(".svg", ".png")
    subprocess.run(
        [
            "resvg",
            "--width",
            str(SIZE),
            "--height",
            str(SIZE),
            str(directory / name),
            str(png),
        ],
        check=True,
        stdout=subprocess.DEVNULL,
    )
    return png.read_bytes()


def main():
    upstream, templates = (
        pathlib.Path(argument) for argument in sys.argv[1:3]
    )

    have = {path.name for path in templates.glob("*.svg")}
    want = {path.name for path in upstream.glob("*.svg")}
    if have != want:
        missing = "\n".join(
            f"  missing template: {name}" for name in sorted(want - have)
        )
        extra = "\n".join(
            f"  no upstream source: {name}" for name in sorted(have - want)
        )
        sys.exit(
            "identity: template set does not match upstream — re-run "
            f"`nix run .#update-cursor-templates`\n{missing}\n{extra}".rstrip()
        )

    differing = []
    with tempfile.TemporaryDirectory() as scratch:
        a, b = pathlib.Path(scratch) / "a", pathlib.Path(scratch) / "b"
        a.mkdir()
        b.mkdir()
        for name in sorted(want):
            if render(upstream, name, a) != render(templates, name, b):
                differing.append(name)

    if differing:
        listing = "\n".join(f"  {name}" for name in differing)
        sys.exit(
            f"identity: {len(differing)} template(s) no longer render as "
            f"upstream Breeze:\n{listing}"
        )

    print(f"identity: {len(want)} templates render identically to upstream")


if __name__ == "__main__":
    main()
