"""Tile every shape in a compiled cursor theme into one PNG.

`checks.cursorIdentity` and `checks.cursorSlotLeak` between them prove a theme
is faithful to Breeze and reachable from the palette. Neither has an opinion on
whether it looks any good, which is what this is for — the pointer is the one
themed surface you cannot take a screenshot of.

Each shape is drawn twice, over a dark and a light surface, because one cursor
has to work on both and the failure mode is a body that vanishes into the
background it sits on.

Usage: preview-cursors.py <theme-dir-or-package> [out.png] [dark-bg] [light-bg]
"""

import pathlib
import subprocess
import sys
import tempfile

from PIL import Image, ImageDraw, ImageFont

CELL = 64
PAD = 10
LABEL = 13
COLUMNS = 10
HEAD = 26


def theme_dir(argument):
    """Accept either a theme directory or the package that carries one."""
    path = pathlib.Path(argument)
    if (path / "cursors_scalable").is_dir():
        return path
    found = sorted(path.glob("share/icons/*/cursors_scalable"))
    if not found:
        sys.exit(f"preview: no cursor theme under {path}")
    return found[0].parent


def main():
    if not 2 <= len(sys.argv) <= 5:
        sys.exit(__doc__.strip().splitlines()[-1])
    theme = theme_dir(sys.argv[1])
    output = pathlib.Path(
        sys.argv[2] if len(sys.argv) > 2 else f"{theme.name}.png"
    )
    dark = sys.argv[3] if len(sys.argv) > 3 else "#1c1c1c"
    light = sys.argv[4] if len(sys.argv) > 4 else "#e8e8e8"

    # One frame per shape: an animation's later frames say nothing new about
    # the palette.
    shapes = sorted(
        path
        for path in (theme / "cursors_scalable").iterdir()
        if path.is_dir() and not path.is_symlink()
    )

    cell_width = CELL * 2 + PAD * 2
    cell_height = CELL + PAD * 2 + LABEL
    rows = -(-len(shapes) // COLUMNS)
    sheet = Image.new(
        "RGB", (cell_width * COLUMNS, cell_height * rows + HEAD), "#2b2b2b"
    )
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    draw.text(
        (8, 8),
        f"{theme.name} - {len(shapes)} shapes",
        fill="#ffffff",
        font=font,
    )

    with tempfile.TemporaryDirectory() as scratch:
        png = pathlib.Path(scratch) / "frame.png"
        for index, shape in enumerate(shapes):
            frame = sorted(shape.glob("*.svg"))[0]
            subprocess.run(
                [
                    "resvg",
                    "--width",
                    str(CELL),
                    "--height",
                    str(CELL),
                    str(frame),
                    str(png),
                ],
                check=True,
                stdout=subprocess.DEVNULL,
            )
            image = Image.open(png).convert("RGBA")

            row, column = divmod(index, COLUMNS)
            x, y = column * cell_width, row * cell_height + HEAD
            draw.rectangle(
                [x, y, x + cell_width // 2, y + cell_height], fill=dark
            )
            draw.rectangle(
                [x + cell_width // 2, y, x + cell_width, y + cell_height],
                fill=light,
            )
            sheet.paste(image, (x + PAD, y + PAD), image)
            sheet.paste(image, (x + PAD + CELL, y + PAD), image)
            draw.text(
                (x + 3, y + cell_height - LABEL),
                shape.name[:22],
                fill="#e8e8e8",
                font=font,
            )

    sheet.save(output)
    print(f"preview: {len(shapes)} shapes -> {output}")


if __name__ == "__main__":
    main()
