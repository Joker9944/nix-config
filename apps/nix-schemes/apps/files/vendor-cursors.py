"""Annotate Breeze's cursor SVGs with the palette slot each paint belongs to.

XCursor is pre-baked pixmaps, so there is nothing to recolour after the fact —
the way in is upstream of the format, at the SVGs Breeze is drawn in. Those
name only some of their paints: 196 of 344 elements carry no `fill` and take
the SVG default of black, which covers the cursor body, every drop shadow and
`crosshair.svg`'s gradient stops alike.

Two signals separate them. `filter="url(#…)"` marks a shadow — in all 91 files
it appears only on blurred copies, always paired with `opacity`. Its absence
marks body. The effective paint has to be resolved down the tree rather than
read per element, because `help.svg` draws a `<circle>` that inherits `fill`
from a `<g>` ancestor.

The literal is kept and the slot recorded beside it in `data-slot`, so a
template still renders as upstream Breeze. That is what `checks.cursorIdentity`
compares, and it is why the check needs no substitution step and no tolerance
for upstream's near-blacks.

Usage: vendor-cursors.py <breeze-checkout>
"""

import json
import pathlib
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET

SVG = "http://www.w3.org/2000/svg"

# Element groups. `PAINT` fills its own geometry; `CONTAINER` only passes paint
# down.
PAINT = {
    f"{{{SVG}}}{tag}"
    for tag in (
        "path",
        "circle",
        "rect",
        "ellipse",
        "polygon",
        "line",
        "polyline",
    )
}
CONTAINER = {f"{{{SVG}}}{tag}" for tag in ("svg", "g", "a")}
STOP = f"{{{SVG}}}stop"

# Every literal Breeze paints with, and the slot it becomes. `None` is the SVG
# default of black, which is a literal in every sense that matters here — it is
# just never written down. Black resolves to `shadow` under a filter and `fill`
# otherwise; upstream's four near-blacks are the same two roles spelled
# inconsistently.
SLOTS = {
    None: "fill",
    "#000": "fill",
    "#000000": "fill",
    "#0d0d0d": "fill",
    "#0a0a0a": "fill",
    "#070707": "fill",
    "#0c0c0c": "fill",
    "#fff": "outline",
    "#ffffff": "outline",
    "#46a7ac": "accent",
    "#d4497f": "accentAlt",
    "#ed1515": "negative",
    "#11d116": "positive",
    "#18c087": "positive",
    "#3daee9": "info",
    "#f67400": "neutral",
}


def classify(paint, under_filter):
    """Slot for a resolved paint, or None if it is not ours to colour."""
    if paint is not None:
        paint = paint.strip().lower()
        # A gradient reference is coloured through the stops it points at.
        if paint.startswith("url(") or paint == "none":
            return None
    slot = SLOTS.get(paint, False)
    if slot is False:
        raise KeyError(paint)
    # Only black is ever shadowed; a filtered accent would be a drawing, not a
    # shadow.
    if under_filter and slot == "fill":
        return "shadow"
    return slot


def annotate(element, inherited, under_filter, unmapped, counts, path):
    """Record the slot of every paint in this subtree, in place."""
    # `display="none"`, never rasterised, and its `#333` is not part of the
    # artwork.
    if element.get("id") == "hotspot":
        return

    declared = element.get("fill")
    effective = declared if declared is not None else inherited
    filtered = under_filter or element.get("filter") is not None

    # A declared paint is annotated wherever it sits, container or not, so that
    # a slot change moves the declaration a child may still be inheriting from.
    subject = (
        element.tag in PAINT or element.tag == STOP or declared is not None
    )
    if element.tag == STOP:
        effective = element.get("stop-color")

    if subject:
        try:
            slot = classify(effective, filtered)
        except KeyError as error:
            unmapped.setdefault(
                error.args[0], f"{path.name}#{element.get('id')}"
            )
            slot = None
        if slot is not None:
            element.set("data-slot", slot)
            counts[slot] = counts.get(slot, 0) + 1

    if element.tag in CONTAINER or element.tag not in PAINT:
        for child in element:
            annotate(child, effective, filtered, unmapped, counts, path)


def working_copy():
    """Where the templates are written — the checkout, never the store."""
    root = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()
    return (
        pathlib.Path(root)
        / "apps"
        / "nix-schemes"
        / "vendor"
        / "cursors"
        / "breeze"
    )


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__.strip().splitlines()[-1])
    source = pathlib.Path(sys.argv[1]) / "cursors" / "Breeze"
    vendor = working_copy()
    # Regenerated wholesale: merging into an existing tree would keep a
    # template for a shape upstream has since dropped.
    shutil.rmtree(vendor, ignore_errors=True)

    ET.register_namespace("", SVG)
    ET.register_namespace("xlink", "http://www.w3.org/1999/xlink")

    svg_out = vendor / "svg"
    svg_out.mkdir(parents=True)

    unmapped = {}
    counts = {}
    trees = {}
    for path in sorted((source / "src" / "svg").glob("*.svg")):
        tree = ET.parse(path)
        annotate(tree.getroot(), None, False, unmapped, counts, path)
        trees[path.name] = tree

    # Validate the whole set before writing, so a new upstream paint cannot
    # leave a half-annotated tree behind. This is the tripwire that surfaces
    # one.
    if unmapped:
        listing = "\n".join(
            f"  {paint}  (e.g. {where})"
            for paint, where in sorted(unmapped.items())
        )
        sys.exit(
            f"vendor-cursors: {len(unmapped)} unmapped paint(s):\n{listing}"
        )

    # Everything below is written rather than copied so the tree already
    # satisfies the `trim-trailing-whitespace` and `end-of-file-fixer` hooks. A
    # hook that rewrote a generated file would put every later regeneration
    # into a diff loop with it.
    for name, tree in trees.items():
        (svg_out / name).write_text(
            ET.tostring(tree.getroot(), encoding="unicode") + "\n"
        )

    # Hotspots, frame delays and nominal sizes come from upstream's own SVG-
    # cursor metadata rather than being recomputed: resolving the `#hotspot`
    # rect through its ancestor transforms is what makes upstream's generator
    # depend on Qt.
    meta_out = vendor / "metadata"
    meta_out.mkdir()
    scalable = source / "Breeze" / "cursors_scalable"
    shapes = 0
    for metadata in sorted(scalable.glob("*/metadata.json")):
        # An alias is a symlink to the shape it points at; `alias.list` carries
        # them.
        if metadata.parent.is_symlink():
            continue
        frames = json.loads(metadata.read_text())
        target = meta_out / f"{metadata.parent.name}.json"
        target.write_text(json.dumps(frames, indent=4, sort_keys=True) + "\n")
        shapes += 1

    for name in ("src/alias.list", "COPYING-ICONS", "AUTHORS"):
        text = (source / name).read_text()
        lines = [line.rstrip() for line in text.rstrip().splitlines()]
        (vendor / pathlib.Path(name).name).write_text("\n".join(lines) + "\n")

    print(f"vendored {len(trees)} templates, {shapes} shapes")
    for slot, count in sorted(counts.items(), key=lambda item: -item[1]):
        print(f"  {slot:<12} x{count}")


if __name__ == "__main__":
    main()
