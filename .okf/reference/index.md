# Reference

External specifications this repo builds on, mirrored only where recall is unreliable and the spec
is awkward to reach mid-task.

# Specifications

* [base24](base24.md) — the five ANSI slots where base16 and base24 disagree, plus which vocabulary each consumer follows.
* [gtk-theming](gtk-theming.md) — why adw-gtk3 is mandatory rather than a convenience, and how a GTK4 theme actually gets applied.
* [cursor-theming](cursor-theming.md) — why a cursor theme is compiled from SVG rather than recoloured, and the nine slots Breeze reduces to.
* [firefox-theming](firefox-theming.md) — how the librewolf theme reaches the browser through the FirefoxColor extension's storage, and what that costs the profile.
* [discord-theming](discord-theming.md) — why Discord's primitive HSL ramps are the layer to override and not its 262 semantic tokens, and how a stylesheet reaches Vesktop.
