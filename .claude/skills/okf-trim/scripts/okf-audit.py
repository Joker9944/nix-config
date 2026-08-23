#!/usr/bin/env python3
"""Rank an OKF bundle's concept files by trim suspicion.

Emits data with provenance, never verdicts. Every check here has a false
positive rate high enough that acting on it unread would be wrong more often
than right; the sections exist to point a reader at lines worth opening.
"""

import argparse
import difflib
import json
import os
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

RESERVED = {"index.md", "log.md"}

# Narrowed against the live bundle: the looser forms of these ("renamed",
# bare "used to", any arrow) fired mostly on live constraints and on the
# instrumental "used to find X", which are not narrative at all.
NARRATIVE_PATTERNS = [
    (
        r"\bused to (?:be|mean|live|sit|hold|carry|have|work|exist)\b",
        "past-tense-about-repo",
    ),
    (r"\bno longer\b", "past-tense-about-repo"),
    (r"\b(?:formerly|previously)\b", "past-tense-about-repo"),
    (
        r"\b(?:was|were|been) renamed\b|\brenamed (?:to|from)\b",
        "rename-narrative",
    ),
    (r"\bmoved (?:to|into|out of|up to)\b", "move-narrative"),
    (
        r"\b(?:replaced (?:by|with)|was replaced|has replaced)\b",
        "replacement-narrative",
    ),
    (r"\bhas since\b", "past-tense-about-repo"),
    # Superseded-state phrasings. These describe the shape the tree used to
    # have, which a reader cannot act on — distinct from a rejected
    # alternative, which stays. A Decision is not exempt from these.
    (
        r"\bbefore (?:this|that)\b|\buntil recently\b|\bat one point\b",
        "superseded-state",
    ),
    (r"\bhad been\b|\bdisplaced\b|\bwhich had\b", "superseded-state"),
    (
        r"\ban earlier (?:draft|version|shape|pass|attempt)\b|\boriginally\b",
        "superseded-state",
    ),
    (
        r"\b(?:will eventually|for now|at the time of writing|we plan to)\b",
        "forward-looking",
    ),
    (r"`[^`]+`\s*→\s*`[^`]+`", "arrow-migration-or-mapping"),
]

# Only agent-directed rules with no repo object. A bare second person is a
# coin flip in this bundle ("one glance tells you what's on" is a fact about
# a manifest) and floods the report, so it is deliberately not matched.
BEHAVIORAL_PATTERNS = [
    (
        r"\bdon'?t (?:guess|recall|reconstruct|reach for|rely on|trust)\b",
        "anti-recall-rule",
    ),
    (r"\brather than (?:recall|guess|reconstruct)", "anti-recall-rule"),
    (
        r"\bstop and\b|\bbefore you (?:write|reach|open|guess)\b",
        "agent-workflow-rule",
    ),
    (
        r"\bprefer (?:this|these|it) over\b"
        r"|\bprefer .{0,30}\bover (?:reading|recall)",
        "tool-preference-rule",
    ),
    (
        r"\b(?:training[- ]data|from memory|your context|hallucinat)\w*",
        "recall-hazard-framing",
    ),
    (r"\byou are about to\b|\byou'?re about to\b", "addresses-the-agent"),
    (
        r"(?im)^\s*(?:\*\s+)?(?:Do not|Don't|Never)\s+(?!.*`)",
        "bare-prohibition-to-reader",
    ),
]

DENSITY_MARKERS = re.compile(
    r"\d|\bbecause\b|\bso that\b|\botherwise\b|\bMiB\b|\bGiB\b|\bms\b", re.I
)

PATHISH = re.compile(r"`([^`\n]+)`")
MD_LINK = re.compile(r"\[([^\]]*)\]\(([^)]+)\)")
FRONTMATTER = re.compile(r"\A---\n(.*?)\n---\n", re.S)
KNOWN_SUFFIXES = (
    ".nix",
    ".md",
    ".sh",
    ".json",
    ".lock",
    ".yaml",
    ".yml",
    ".toml",
    ".lua",
    ".py",
    ".css",
)


def run(cmd, cwd):
    try:
        out = subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=True,
            text=True,
            check=False,
            timeout=60,
        )
        return out.stdout
    except (OSError, subprocess.SubprocessError):
        return ""


def parse_frontmatter(text):
    """Flat key reader. Deliberately not YAML: a PyYAML dependency would make
    the script need a nix shell, and the bundle's frontmatter is flat."""
    match = FRONTMATTER.match(text)
    if not match:
        return {}, text
    block = match.group(1)
    data = {}
    for key in ("type", "title", "description"):
        found = re.search(rf"(?m)^{key}:\s*(.+?)\s*$", block)
        if found:
            data[key] = found.group(1).strip().strip("\"'")
    found = re.search(r"(?m)^generated:.*?\bat:\s*(\S+)", block, re.S)
    if found:
        data["generated_at"] = found.group(1).strip()
    verified_block = re.search(r"(?m)^verified:(.*?)(?=^\w|\Z)", block, re.S)
    if verified_block:
        data["verified_by"] = re.findall(
            r"by:\s*([^\s,}]+)", verified_block.group(1)
        )
    return data, text[match.end() :]


def concept_files(bundle):
    for path in sorted(Path(bundle).rglob("*.md")):
        if path.name in RESERVED:
            continue
        yield path


def strip_code_blocks(text):
    return re.sub(r"```.*?```", "", text, flags=re.S)


def source_lines(text):
    """Yield (lineno, line) for lines outside fenced code blocks. Stripping the
    blocks before splitting shifts every later line number, so fences are
    skipped in place instead."""
    in_fence = False
    for lineno, line in enumerate(text.splitlines(), 1):
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
            continue
        if not in_fence:
            yield lineno, line


def sentences(text):
    """`# Related` sections are parallel by design across every concept and
    swamp the comparison, so they are dropped before splitting."""
    body = re.sub(
        r"(?ms)^#+\s*Related\s*$.*?(?=^#|\Z)", "", strip_code_blocks(text)
    )
    body = re.sub(r"(?m)^\s*[-*]\s+\[.*$", "", body)
    for chunk in re.split(r"(?<=[.!?])\s+|\n\n", body):
        chunk = " ".join(chunk.split())
        if len(chunk) >= 60 and not chunk.startswith(("#", "|")):
            yield chunk


def normalize(text):
    text = re.sub(r"[`*_\[\]()]", "", text.lower())
    return re.sub(r"[^a-z0-9 ]", " ", text)


# --- sections ---------------------------------------------------------------


def scan_lines(bundle, patterns, flags=0):
    hits = []
    for path in concept_files(bundle):
        raw = path.read_text()
        meta, _ = parse_frontmatter(raw)
        for lineno, line in source_lines(raw):
            stripped = line.strip()
            if not stripped or stripped.startswith("#"):
                continue
            for pattern, label in patterns:
                if re.search(pattern, stripped, flags):
                    hits.append(
                        {
                            "file": str(path),
                            "line": lineno,
                            "type": meta.get("type", ""),
                            "kind": label,
                            "dense": bool(DENSITY_MARKERS.search(stripped)),
                            "text": stripped[:200],
                        }
                    )
                    break
    return hits


def section_narrative(bundle):
    return scan_lines(bundle, NARRATIVE_PATTERNS, re.I)


def section_behavioral(bundle):
    return scan_lines(bundle, BEHAVIORAL_PATTERNS)


def section_duplicates(bundle, repo, threshold):
    """Also compares against the repo's skill files: the worst
    restated-authority case is a bundle concept mirroring a
    `.claude/skills/*/SKILL.md`, which a bundle-internal scan can never see."""
    blocks = []
    external = sorted(Path(repo).glob(".claude/skills/*/SKILL.md"))
    for path in [*concept_files(bundle), *external]:
        _, body = parse_frontmatter(path.read_text())
        for sentence in sentences(body):
            blocks.append((str(path), sentence, normalize(sentence)))
    prefix = str(Path(bundle)) + os.sep
    pairs = []
    for i in range(len(blocks)):
        for j in range(i + 1, len(blocks)):
            if blocks[i][0] == blocks[j][0]:
                continue
            if not (
                blocks[i][0].startswith(prefix)
                or blocks[j][0].startswith(prefix)
            ):
                continue
            matcher = difflib.SequenceMatcher(None, blocks[i][2], blocks[j][2])
            if matcher.quick_ratio() < threshold:
                continue
            ratio = matcher.ratio()
            if ratio >= threshold:
                pairs.append(
                    {
                        "ratio": round(ratio, 3),
                        "a_file": blocks[i][0],
                        "b_file": blocks[j][0],
                        "a_text": blocks[i][1][:180],
                        "b_text": blocks[j][1][:180],
                    }
                )
    return sorted(pairs, key=lambda p: -p["ratio"])


def looks_like_path(token):
    """Filters measured against the live bundle. Without the placeholder and
    scheme rules this fires ~49 times on 31 files, essentially all false:
    `hosts/<host>/mixins.nix`, a bare `.nix`, `~/.config/...`,
    `github:owner/repo`."""
    if any(ch in token for ch in "<>~…*?{}|$\\ "):
        return False
    if ":" in token or token.startswith(("http", "/nix/store", "-", "#")):
        return False
    if "/" not in token:
        return token.endswith(KNOWN_SUFFIXES) and not token.startswith(".")
    if token.count("/") == 1 and "." not in token:
        return False
    return True


def strip_anchor(token):
    return token.split("#", 1)[0].strip()


def section_refs(bundle, repo, tracked):
    suspects = []
    for path in concept_files(bundle):
        for lineno, line in source_lines(path.read_text()):
            for raw in PATHISH.findall(line):
                token = strip_anchor(raw).rstrip(".,;").rstrip("/")
                if not looks_like_path(token):
                    continue
                if resolves(token, repo, tracked):
                    continue
                suspects.append(
                    {
                        "file": str(path),
                        "line": lineno,
                        "token": token,
                        "text": line.strip()[:160],
                    }
                )
    return suspects


def resolves(token, repo, tracked):
    if (Path(repo) / token).exists():
        return True
    if token in tracked:
        return True
    suffix = "/" + token
    return any(
        p == token or p.endswith(suffix) or p.startswith(token + "/")
        for p in tracked
    )


def section_churn(bundle, repo, tracked):
    rows = []
    for path in concept_files(bundle):
        meta, body = parse_frontmatter(path.read_text())
        since = meta.get("generated_at")
        refs = set()
        for raw in PATHISH.findall(strip_code_blocks(body)):
            token = strip_anchor(raw).rstrip(".,;").rstrip("/")
            if looks_like_path(token) and resolves(token, repo, tracked):
                refs.add(token)
        if not since or not refs:
            rows.append(
                {
                    "file": str(path),
                    "since": since,
                    "refs": len(refs),
                    "commits": None,
                }
            )
            continue
        out = run(
            [
                "git",
                "log",
                "--oneline",
                f"--since={since}",
                "--",
                *sorted(refs),
            ],
            repo,
        )
        rows.append(
            {
                "file": str(path),
                "since": since,
                "refs": len(refs),
                "commits": len([ln for ln in out.splitlines() if ln.strip()]),
            }
        )
    return sorted(
        rows, key=lambda r: (r["commits"] is None, -(r["commits"] or 0))
    )


def section_log(bundle):
    log = Path(bundle) / "log.md"
    if not log.exists():
        return {}
    lines = log.read_text().splitlines()
    entries, dates, current = [], [], None
    per_date = defaultdict(int)
    for line in lines:
        heading = re.match(r"^##\s+(\d{4}-\d{2}-\d{2})\s*$", line)
        if heading:
            current = heading.group(1)
            dates.append(current)
            continue
        if re.match(r"^\s*[-*]\s+\S", line):
            entry = line.strip()[2:].strip()
            links = MD_LINK.findall(entry)
            # Strip every trailing link, not just the first: entries carry
            # several separated by commas, and counting those as prose
            # overstates the length.
            prose = re.sub(
                r"(\s*[—,]\s*\[[^\]]*\]\([^)]*\))+\s*$", "", entry
            ).strip()
            entries.append(
                {
                    "date": current,
                    "chars": len(entry),
                    "prose_chars": len(prose),
                    "links": len(links),
                    "sha": bool(re.search(r"—\s*[0-9a-f]{7}\s*(—|$)", entry)),
                    "text": entry[:120],
                }
            )
            if current:
                per_date[current] += 1
    sizes = sorted(e["chars"] for e in entries) or [0]
    prose = sorted(e["prose_chars"] for e in entries) or [0]
    return {
        "entries": len(entries),
        "dates": dates,
        "chars_min": sizes[0],
        "chars_median": sizes[len(sizes) // 2],
        "chars_max": sizes[-1],
        "prose_median": prose[len(prose) // 2],
        "prose_max": prose[-1],
        "over_budget": sum(1 for e in entries if e["prose_chars"] > 100),
        "with_sha": sum(1 for e in entries if e["sha"]),
        "no_link": sum(1 for e in entries if e["links"] == 0),
        "multi_link": sum(1 for e in entries if e["links"] > 1),
        "merge_candidates": {d: n for d, n in per_date.items() if n > 2},
        "longest": sorted(entries, key=lambda e: -e["chars"])[:5],
    }


def section_index_pairing(bundle):
    rows = []
    for index in sorted(Path(bundle).rglob("index.md")):
        for line in index.read_text().splitlines():
            if not re.match(r"^\s*[-*]\s+\[", line):
                continue
            link = MD_LINK.search(line)
            if not link:
                continue
            target = (index.parent / link.group(2).split("#")[0]).resolve()
            bullet = line.split("—", 1)[1].strip() if "—" in line else ""
            if not target.is_file():
                rows.append(
                    {
                        "index": str(index),
                        "target": link.group(2),
                        "missing": True,
                    }
                )
                continue
            meta, _ = parse_frontmatter(target.read_text())
            rows.append(
                {
                    "index": str(index),
                    "target": os.path.relpath(target, bundle),
                    "bullet": bullet,
                    "description": meta.get("description", ""),
                    "missing": False,
                }
            )
    return rows


def section_links(bundle):
    bundle = Path(bundle).resolve()
    broken = []
    for path in sorted(bundle.rglob("*.md")):
        for lineno, line in enumerate(path.read_text().splitlines(), 1):
            for _, target in MD_LINK.findall(line):
                target = target.split("#")[0].strip()
                if not target or target.startswith(("http", "mailto:")):
                    continue
                base = bundle if target.startswith("/") else path.parent
                resolved = (base / target.lstrip("/")).resolve()
                if not resolved.exists():
                    broken.append(
                        {"file": str(path), "line": lineno, "target": target}
                    )
    return broken


def section_trust(bundle):
    rows = []
    for path in concept_files(bundle):
        meta, _ = parse_frontmatter(path.read_text())
        verifiers = meta.get("verified_by", [])
        rows.append(
            {
                "file": str(path),
                "type": meta.get("type", ""),
                "generated_at": meta.get("generated_at", ""),
                "tier": "human-reviewed"
                if any(v.startswith("human:") for v in verifiers)
                else ("machine-confirmed" if verifiers else "unverified"),
                "verified_by": verifiers,
            }
        )
    return rows


# --- reporting --------------------------------------------------------------


def emit_text(report, out):
    def head(title, count):
        print(f"\n=== {title} ({count}) ===", file=out)

    head(
        "narrative — Test C; rewrite to the present, cut if nothing survives",
        len(report["narrative"]),
    )
    for hit in report["narrative"]:
        tag = f"{hit['type']}/" if hit["type"] else ""
        print(
            f"  {hit['file']}:{hit['line']} "
            f"[{tag}{hit['kind']}] {hit['text']}",
            file=out,
        )

    head(
        "duplicate paragraphs — one authority, link from the other",
        len(report["duplicates"]),
    )
    for pair in report["duplicates"]:
        print(f"  {pair['ratio']}  {pair['a_file']}", file=out)
        print(f"         vs  {pair['b_file']}", file=out)
        print(f"      A: {pair['a_text']}", file=out)
        print(f"      B: {pair['b_text']}", file=out)

    head(
        "behavioral candidates — apply the subject test before cutting",
        len(report["behavioral"]),
    )
    for hit in report["behavioral"]:
        flag = "DENSE " if hit["dense"] else ""
        print(
            f"  {hit['file']}:{hit['line']} "
            f"[{flag}{hit['kind']}] {hit['text']}",
            file=out,
        )

    head(
        "reference suspects — unresolved; upstream and generated paths too",
        len(report["refs"]),
    )
    for hit in report["refs"]:
        print(f"  {hit['file']}:{hit['line']}  `{hit['token']}`", file=out)
        print(f"      {hit['text']}", file=out)

    head(
        "broken bundle links — the validator does not catch these (SPEC §11)",
        len(report["links"]),
    )
    for hit in report["links"]:
        print(f"  {hit['file']}:{hit['line']} -> {hit['target']}", file=out)

    head("churn — READING ORDER ONLY, never a defect", len(report["churn"]))
    for row in report["churn"][:12]:
        commits = "n/a" if row["commits"] is None else row["commits"]
        print(
            f"  {commits:>4} commits since {row['since']}  {row['file']}",
            file=out,
        )

    verified = [r for r in report["trust"] if r["tier"] != "unverified"]
    head(
        "trust tiers — human-reviewed files need a consult before editing",
        len(verified),
    )
    for row in verified:
        print(
            f"  {row['tier']:<18} {row['file']}  {row['verified_by']}",
            file=out,
        )

    head(
        "index bullets vs frontmatter descriptions — scan for contradictions",
        len(report["index"]),
    )
    for row in report["index"]:
        if row.get("missing"):
            print(
                f"  MISSING TARGET {row['index']} -> {row['target']}", file=out
            )
            continue
        print(f"  {row['target']}", file=out)
        print(f"      bullet: {row['bullet']}", file=out)
        print(f"      descr : {row['description']}", file=out)

    log = report["log"]
    if log:
        print("\n=== log.md ===", file=out)
        print(
            f"  {log['entries']} entries over {len(log['dates'])} dates; "
            f"chars min/median/max {log['chars_min']}"
            f"/{log['chars_median']}/{log['chars_max']}",
            file=out,
        )
        print(
            f"  prose only (link markup excluded): "
            f"median {log['prose_median']}, max {log['prose_max']}; "
            f"{log['over_budget']} over the ~100-char budget",
            file=out,
        )
        print(
            f"  {log['with_sha']} carry a SHA, {log['no_link']} have no link, "
            f"{log['multi_link']} have several",
            file=out,
        )
        if log["merge_candidates"]:
            print(
                f"  merge candidates (>2 entries in a day): "
                f"{log['merge_candidates']}",
                file=out,
            )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bundle", default=".okf")
    parser.add_argument("--repo", default=".")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--duplicate-threshold", type=float, default=0.6)
    args = parser.parse_args()

    bundle = Path(args.bundle)
    if not bundle.is_dir():
        print(f"okf-audit: no bundle at {bundle}", file=sys.stderr)
        return 2

    tracked = set(run(["git", "ls-files"], args.repo).splitlines())

    report = {
        "bundle": str(bundle),
        "repo": str(args.repo),
        "narrative": section_narrative(bundle),
        "duplicates": section_duplicates(
            bundle, args.repo, args.duplicate_threshold
        ),
        "behavioral": section_behavioral(bundle),
        "refs": section_refs(bundle, args.repo, tracked),
        "links": section_links(bundle),
        "churn": section_churn(bundle, args.repo, tracked),
        "trust": section_trust(bundle),
        "index": section_index_pairing(bundle),
        "log": section_log(bundle),
    }

    if args.json:
        json.dump(report, sys.stdout, indent=2)
        print()
    else:
        emit_text(report, sys.stdout)
    return 0


if __name__ == "__main__":
    sys.exit(main())
