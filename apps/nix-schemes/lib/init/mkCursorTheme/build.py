#!/usr/bin/env python3
"""Compile the vendored Breeze cursor templates into a theme in three formats.

XCursor is pre-baked pixmaps, so a cursor theme cannot be recoloured the way an
icon pack can — it has to be compiled from the SVGs it was drawn in. Each
template carries a `data-slot` on every paint it owns (written by
`apps/files/vendor-cursors.py`); this resolves those against a scheme, then
rasterises, packs and writes out:

  cursors/           XCursor, for XWayland, GTK and anything on XCURSOR_THEME
  cursors_scalable/  KDE's SVG cursor format, read by KWin
  hyprcursors/       hyprcursor, which renders SVG at the size asked for

Hotspots, frame delays and nominal sizes are read from the vendored upstream
metadata rather than recomputed from the `#hotspot` rect, which would mean
composing ancestor transforms — `crosshair.svg`'s carries
`transform="rotate(90)"`.

Usage: build.py <templates> <colours.json> <name> <theme-dir>
"""

import json
import math
import pathlib
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET
import zipfile

SVG = "http://www.w3.org/2000/svg"
STOP = f"{{{SVG}}}stop"

# Nominal sizes to pack, i.e. what a consumer means by XCURSOR_SIZE. Upstream
# ships a percentage ladder that skips 16; this is spelled in nominal sizes so
# the set consumers actually ask for is the set that exists.
SIZES = [12, 16, 18, 24, 32, 36, 48, 64, 72, 96]

# Nudge the hotspot off an exact half before flooring, so float error in a
# scaled coordinate cannot drop it a pixel. Upstream's `generate_cursors` does
# the same, and `size_bdiag`'s 15.499780617600003 is why either of us bothers.
DISPLACE = 0.01

# The earliest a DOS timestamp can express, and so the conventional stand-in
# for "no time at all" in a zip.
EPOCH = (1980, 1, 1, 0, 0, 0)


# Painting the templates


def resolve_slots(path, colours):
    """Paint one template from the palette. Returns (tree, canvas edge)."""
    tree = ET.parse(path)
    root = tree.getroot()
    for element in root.iter():
        slot = element.get("data-slot")
        if slot is None:
            continue
        if slot not in colours:
            sys.exit(f"build: {path.name} wants unknown slot {slot!r}")
        element.set(
            "stop-color" if element.tag == STOP else "fill", colours[slot]
        )
        # The annotation is scaffolding for the build, not part of the artwork,
        # and `cursors_scalable` is specified as SVG Tiny 1.2.
        del element.attrib["data-slot"]
    return tree, float(root.get("width"))


def paint_templates(source, colours, into):
    """Paint every template into `into`. Returns each canvas edge by stem."""
    into.mkdir(parents=True)
    canvas = {}
    for path in sorted(source.glob("*.svg")):
        tree, edge = resolve_slots(path, colours)
        (into / path.name).write_bytes(ET.tostring(tree.getroot()))
        canvas[path.stem] = edge
    return canvas


# XCursor


def render(svg, png, edge):
    arguments = ["--width", str(edge), "--height", str(edge)]
    subprocess.run(["resvg"] + arguments + [str(svg), str(png)], check=True)


def xcursor_rows(frames, svg_dir, canvas, work):
    """Rasterise every frame at every size. Returns config rows by size."""
    rows = {size: [] for size in SIZES}
    for frame in frames:
        stem = pathlib.Path(frame["filename"]).stem
        nominal = frame["nominal_size"]
        delay = frame.get("delay")
        for size in SIZES:
            # The pixmap is the canvas scaled against the *nominal* size, so a
            # request for Breeze's nominal 24 renders its 32-unit canvas at
            # 32px. Both numbers are read per file rather than assumed.
            edge = math.floor(canvas[stem] * size / nominal)
            png = work / f"x{size}" / f"{stem}.png"
            png.parent.mkdir(parents=True, exist_ok=True)
            render(svg_dir / f"{stem}.svg", png, edge)

            x = math.floor(frame["hotspot_x"] * size / nominal + DISPLACE)
            y = math.floor(frame["hotspot_y"] * size / nominal + DISPLACE)
            row = f"{size} {x} {y} {png}"
            rows[size].append(row + (f" {delay}" if delay else ""))
    return rows


def write_xcursor(target, frames, svg_dir, canvas, work):
    """Pack one shape's pixmaps into an XCursor file at `target`."""
    rows = xcursor_rows(frames, svg_dir, canvas, work)
    # xcursorgen reads an animation as consecutive images of the same size, so
    # the config is grouped by size with the frames of each in order.
    config = work / f"{target.name}.config"
    config.write_text(
        "\n".join(row for size in SIZES for row in rows[size]) + "\n"
    )
    subprocess.run(["xcursorgen", str(config), str(target)], check=True)


# KDE's cursors_scalable


def write_scalable(target, frames, svg_dir):
    """One shape as painted SVG, beside the upstream metadata for it."""
    target.mkdir(parents=True)
    (target / "metadata.json").write_text(json.dumps(frames, indent=4) + "\n")
    for frame in frames:
        name = frame["filename"]
        shutil.copyfile(svg_dir / name, target / name)


# hyprcursor


def write_hyprcursor_shape(target, name, frames, svg_dir, canvas, aliases):
    """One shape of a hyprcursor working state: frames plus its `meta.hl`."""
    target.mkdir(parents=True)

    # hyprcursor renders an SVG into a size*size box and has no notion of a
    # nominal size, so its hotspot is a fraction of the canvas rather than of
    # the 24 the other two formats scale against.
    first = frames[0]
    edge = canvas[pathlib.Path(first["filename"]).stem]
    meta = [
        "resize_algorithm = bilinear",
        f"hotspot_x = {first['hotspot_x'] / edge}",
        f"hotspot_y = {first['hotspot_y'] / edge}",
        f"define_override = {name}",
    ]
    # hyprcursor has no symlinks; an alias is a name the shape answers to.
    meta += [f"define_override = {alias}" for alias in aliases]

    for frame in frames:
        filename = frame["filename"]
        shutil.copyfile(svg_dir / filename, target / filename)
        delay = frame.get("delay")
        # Size 0 means "take the SVG whole"; repeating it animates the shape.
        meta.append(
            f"define_size = 0, {filename}" + (f", {delay}" if delay else "")
        )

    (target / "meta.hl").write_text("\n".join(meta) + "\n")


def undate(archive):
    """Restamp one `.hlc` at the epoch, in place.

    An `.hlc` is a zip, and hyprcursor-util writes wall-clock time into every
    entry — enough on its own to make the derivation fail `nix build
    --rebuild`. Nothing reads these timestamps.
    """
    with zipfile.ZipFile(archive) as source:
        entries = [
            (info, source.read(info.filename)) for info in source.infolist()
        ]
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as target:
        for info, data in entries:
            stamped = zipfile.ZipInfo(info.filename, EPOCH)
            stamped.compress_type = info.compress_type
            stamped.external_attr = info.external_attr
            target.writestr(stamped, data)


def compile_hyprcursor(workspace, name, work, theme):
    """Run hyprcursor-util over the working state and install what it wrote."""
    (workspace / "manifest.hl").write_text(
        f"name = {name}\n"
        f"description = Breeze cursors recoloured for {name}\n"
        "version = 1.0\n"
        "cursors_directory = hyprcursors\n"
    )
    subprocess.run(
        ["hyprcursor-util", "--create", str(workspace), "--output", str(work)],
        check=True,
    )
    # hyprcursor-util names its output after the manifest, not `--output`.
    compiled = next(work.glob("theme_*"))
    shutil.move(compiled / "hyprcursors", theme / "hyprcursors")
    shutil.move(compiled / "manifest.hl", theme / "manifest.hl")

    for archive in sorted((theme / "hyprcursors").glob("*.hlc")):
        undate(archive)


# Aliases and theme metadata


def read_aliases(path, shapes):
    """`<alias> <target>` pairs from `alias.list`, minus the false ones."""
    pairs = []
    for line in path.read_text().splitlines():
        if not line:
            continue
        alias, target = line.split()
        # A few names on that list are shapes drawn in their own right —
        # `alias` itself among them. Those lines alias nothing.
        if alias not in shapes:
            pairs.append((alias, target))
    return pairs


def link_aliases(aliases, directories):
    """Both pixmap formats resolve an alias by symlink; hyprcursor does not."""
    for alias, target in aliases:
        for directory in directories:
            (directory / alias).symlink_to(target)


def write_index_theme(theme, name):
    (theme / "index.theme").write_text(
        "[Icon Theme]\n"
        f"Name={name}\n"
        f"Comment=Breeze cursors recoloured for {name}\n"
    )


def main():
    if len(sys.argv) != 5:
        sys.exit(__doc__.strip().splitlines()[-1])
    templates = pathlib.Path(sys.argv[1])
    colours = json.loads(pathlib.Path(sys.argv[2]).read_text())
    name = sys.argv[3]
    theme = pathlib.Path(sys.argv[4])

    ET.register_namespace("", SVG)
    ET.register_namespace("xlink", "http://www.w3.org/1999/xlink")

    work = pathlib.Path("build")
    svg_dir = work / "svg"
    canvas = paint_templates(templates / "svg", colours, svg_dir)

    shapes = {
        path.stem: json.loads(path.read_text())
        for path in sorted((templates / "metadata").glob("*.json"))
    }
    aliases = read_aliases(templates / "alias.list", set(shapes))
    aliased = {}
    for alias, target in aliases:
        aliased.setdefault(target, []).append(alias)

    cursors = theme / "cursors"
    scalable = theme / "cursors_scalable"
    workspace = work / "hyprcursor"
    cursors.mkdir(parents=True)

    for shape, frames in shapes.items():
        write_xcursor(cursors / shape, frames, svg_dir, canvas, work)
        write_scalable(scalable / shape, frames, svg_dir)
        write_hyprcursor_shape(
            workspace / "hyprcursors" / shape,
            shape,
            frames,
            svg_dir,
            canvas,
            aliased.get(shape, []),
        )

    link_aliases(aliases, (cursors, scalable))
    compile_hyprcursor(workspace, name, work, theme)
    write_index_theme(theme, name)

    print(f"built {len(list(cursors.iterdir()))} cursors in {theme}")


if __name__ == "__main__":
    main()
