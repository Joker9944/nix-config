#!/usr/bin/env python3
"""Point an icon theme's ColorScheme stylesheets at a scheme's colours.

Icon packs written for Plasma carry a `<style>` element whose `.ColorScheme-*` rules
set `color:`, and draw their elements with `fill="currentColor"`. Plasma swaps those
declarations for the live colour scheme before rasterising; GTK has no equivalent hook,
so they are rewritten here instead. Only the declarations change — never an element.

`*-symbolic.svg` is skipped. GTK recolours those itself, keyed on the filename, by
wrapping them in a stylesheet using `!important`, so anything written here is discarded.

Usage: recolour.py <icons-tree> <colours.json>
"""

import json
import os
import re
import sys
import xml.etree.ElementTree as ET
from collections import Counter

SYMBOLIC = ("-symbolic.svg", "-symbolic-ltr.svg", "-symbolic-rtl.svg")

CLASS_TOKEN = re.compile(r"ColorScheme-[A-Za-z0-9_]+")
# `<style>` cannot nest, so its span is unambiguous without parsing.
STYLE_SPAN = re.compile(r"(<style\b[^>]*>)(.*?)(</style>)", re.S)
CSS_RULE = re.compile(r"([^{}]*)\{([^{}]*)\}", re.S)
COLOR_DECL = re.compile(r"(color\s*:\s*)([^;}]*)")
SVG_OPEN = re.compile(r"<svg\b[^>]*?(/?)>", re.S)
PAINT_DECL = re.compile(r"(?:^|;)\s*(fill|stroke)\s*:\s*([^;]+)")


def svg_files(tree):
    """Real .svg files, never symlinks — a pack dedupes by linking."""
    for dirpath, dirnames, filenames in os.walk(tree):
        dirnames.sort()
        for name in sorted(filenames):
            if not name.endswith(".svg") or name.endswith(SYMBOLIC):
                continue
            path = os.path.join(dirpath, name)
            if not os.path.islink(path):
                yield path


def classes_in_document(path):
    """Classes a `class=` attribute actually references, plus literal-paint count.

    Parsed rather than matched, so a `ColorScheme-` string in a comment or in
    Inkscape metadata is not mistaken for a class.
    """
    root = ET.parse(path).getroot()
    used = set()
    literal = 0
    for element in root.iter():
        value = element.get("class")
        if not value:
            continue
        names = CLASS_TOKEN.findall(value)
        if not names:
            continue
        used.update(names)
        # Any of `fill=`, `stroke=`, `style="fill:…"` and `style="stroke:…"` may carry the
        # `currentColor` that picks the rule up, and a `style` declaration outranks the
        # presentation attribute of the same name.
        inline = {
            prop: value.strip()
            for prop, value in PAINT_DECL.findall(element.get("style") or "")
        }
        for attribute in ("fill", "stroke"):
            paint = inline.get(attribute, element.get(attribute))
            if paint and paint not in ("currentColor", "none"):
                literal += 1
    return used, literal


def rewrite_rules(body, colours, seen):
    """Replace `color:` in every `.ColorScheme-*` rule; leave other CSS alone."""
    defined = set()

    def rule(match):
        selector, declarations = match.group(1), match.group(2)
        names = CLASS_TOKEN.findall(selector)
        if not names:
            return match.group(0)
        defined.update(names)
        colour = colours[names[0]]
        for name in names:
            seen[name] += 1
        if not COLOR_DECL.search(declarations):
            declarations = f"{declarations.rstrip().rstrip(';')};color:{colour};"
            return f"{selector}{{{declarations}}}"
        return f"{selector}{{{COLOR_DECL.sub(rf'\1{colour}', declarations)}}}"

    return CSS_RULE.sub(rule, body), defined


def stylesheet(names, colours):
    return "".join(f".{name} {{ color:{colours[name]}; }}" for name in sorted(names))


def recolour(path, colours, stats):
    used, literal = classes_in_document(path)
    if not used:
        stats["files-without-class"] += 1
        return False
    stats["literal-paint-wins"] += literal

    source = open(path, encoding="utf-8").read()
    defined = set()

    def block(match):
        nonlocal defined
        body, found = rewrite_rules(match.group(2), colours, stats["class"])
        defined |= found
        return f"{match.group(1)}{body}{match.group(3)}"

    result = STYLE_SPAN.sub(block, source)

    missing = used - defined
    if missing:
        rules = stylesheet(missing, colours)
        for name in missing:
            stats["class"][name] += 1
        first = STYLE_SPAN.search(result)
        if first:
            # A class is used but no rule declares it; extend the existing sheet.
            result = result[: first.end(2)] + rules + result[first.end(2) :]
            stats["rules-appended"] += 1
        else:
            # No stylesheet at all: under Plasma the engine supplies one, under GTK
            # nothing does, so these render at the CSS initial colour until injected.
            opening = SVG_OPEN.search(result)
            if not opening or opening.group(1):
                stats["unstyleable"] += 1
                return False
            injected = f'<defs><style id="current-color-scheme" type="text/css">{rules}</style></defs>'
            result = result[: opening.end()] + injected + result[opening.end() :]
            stats["stylesheets-injected"] += 1

    if result == source:
        return False

    ET.fromstring(result)
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(result)
    return True


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__.strip().splitlines()[-1])
    tree, colour_file = sys.argv[1], sys.argv[2]
    with open(colour_file, encoding="utf-8") as handle:
        colours = json.load(handle)

    # Validate the whole tree before writing anything, so an unmapped class cannot
    # leave a half-recoloured theme behind.
    unknown = {}
    total = 0
    for path in svg_files(tree):
        total += 1
        try:
            used, _ = classes_in_document(path)
        except ET.ParseError as error:
            sys.exit(
                f"recolour: {os.path.relpath(path, tree)} is not well-formed XML: {error}"
            )
        for name in used - set(colours):
            unknown.setdefault(name, os.path.relpath(path, tree))
    if unknown:
        listing = "\n".join(
            f"  {name}  (e.g. {where})" for name, where in sorted(unknown.items())
        )
        sys.exit(f"recolour: {len(unknown)} unmapped ColorScheme class(es):\n{listing}")

    stats = Counter()
    stats["class"] = Counter()
    changed = sum(recolour(path, colours, stats) for path in svg_files(tree))

    print(f"recoloured {changed} of {total} non-symbolic svg files")
    for key in (
        "stylesheets-injected",
        "rules-appended",
        "files-without-class",
        "literal-paint-wins",
        "unstyleable",
    ):
        if stats[key]:
            print(f"  {key:<22} {stats[key]}")
    for name, count in stats["class"].most_common():
        print(f"  {name:<32} {colours[name]}  x{count}")


if __name__ == "__main__":
    main()
