#!/usr/bin/env python3
"""Assert every paint in a compiled theme came through the slot table.

The theme under test is built with all nine slots mapped to distinct pure reds,
chosen so that `green == blue` — a property every blend and antialiased edge
between them preserves. A paint the classifier never annotated keeps whatever
Breeze baked in, and Breeze's own palette is teal, pink, orange, green, blue,
white and black. None of those survive the test below, so an escapee is
chromatically impossible to hide.

This is the complement of `identity.py`. That one proves the templates still
*look* like Breeze; this one proves every part of them is actually reachable
from the palette.

Usage: slot-leak.py <theme-dir>
"""

import pathlib
import subprocess
import sys
import tempfile
from collections import Counter

from PIL import Image

SIZE = 64


def offenders(png):
    """Solid pixels outside the pure-red family, counted by colour."""
    found = Counter()
    pixels = Image.open(png).convert("RGBA").tobytes()
    for index in range(0, len(pixels), 4):
        red, green, blue, alpha = pixels[index : index + 4]
        if alpha != 255:
            continue
        if (
            green <= red
            and blue <= red
            and abs(green - blue) <= 6
            and red - green >= 8
        ):
            continue
        found[(red, green, blue)] += 1
    return found


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__.strip().splitlines()[-1])
    theme = pathlib.Path(sys.argv[1])

    # `cursors_scalable` is the substituted SVG exactly as the theme ships it,
    # so this tests the real build rather than a re-implementation of it. An
    # alias is a symlink to a shape directory, and globbing walks into it.
    sources = sorted(
        path
        for path in (theme / "cursors_scalable").glob("*/*.svg")
        if not path.parent.is_symlink()
    )
    if not sources:
        sys.exit(f"slot-leak: no scalable cursors under {theme}")

    scanned = 0
    leaks = {}
    with tempfile.TemporaryDirectory() as scratch:
        png = pathlib.Path(scratch) / "frame.png"
        for source in sources:
            subprocess.run(
                [
                    "resvg",
                    "--width",
                    str(SIZE),
                    "--height",
                    str(SIZE),
                    str(source),
                    str(png),
                ],
                check=True,
                stdout=subprocess.DEVNULL,
            )
            found = offenders(png)
            scanned += 1
            if found:
                leaks[f"{source.parent.name}/{source.name}"] = found

    if leaks:
        listing = "\n".join(
            f"  {where}: "
            + ", ".join(
                f"#{r:02x}{g:02x}{b:02x} x{n}"
                for (r, g, b), n in found.most_common(4)
            )
            for where, found in sorted(leaks.items())
        )
        sys.exit(
            f"slot-leak: {len(leaks)} file(s) paint outside the "
            f"palette:\n{listing}"
        )

    print(f"slot-leak: {scanned} frames, every solid pixel came from a slot")


if __name__ == "__main__":
    main()
