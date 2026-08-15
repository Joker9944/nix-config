---
type: Playbook
title: Inspect a resolved color scheme
description: Dump a hyprland style's scheme after every transformer has run, with `nix run .#scheme-spec <theme>` — and why the app resolves the flake at build time rather than through `builtins.getFlake`.
tags: [workflow, schemes, hyprland, debugging]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-15T00:00:00Z
---

# Dump a scheme

```console
$ nix run .#scheme-spec uwunicorn | jq '.palette.base00, .accent'
$ nix run .#scheme-spec            # lists the available themes
```

The output is the scheme *after* the style's transformer chain — what the system actually
themes with, not what the upstream base16/base24 file says. For `uwunicorn` that means the
24-colour palette `interpolateBase24` derived from a 16-colour source; for both styles it
means the `named` groups, the `ansi` map and the GTK `accent`.

Shape: `system` / `name` / `author` / `variant`, a `palette` (`base00`…`base17`), an `ansi`
map (`0`…`F`), named groups (`background` and `foreground` carry five shades, the eight
colour names carry `dull` and `bright`), and the flat `accent` / `error` / `warning` / `info`.
Every colour is `{ hex, rgb, dec }`.

# How it is built

`flake.lib.schemes.mkSchemeSpecs` reads the theme list from the `style.theme` option's own
enum, then re-evaluates the home configuration once per theme with that theme forced
(`extendModules`), and flattens each result with `libSchemes.toSpec`. A new style under
`users/mixins/desktop-environment/hyprland/styling/` therefore shows up with no change here.

# Why not `builtins.getFlake "$PWD"`

The `obfuscate` app reaches the flake that way, and it is a trap for anything that touches
the module tree. An impure path flakeref copies the **working tree**; `nix build` and
`nix flake check` use the **git tree**. Those differ, and untracked files are not the only
reason — git cannot track an empty directory at all.

`hosts/mixins/desktop-environment/hyprland/files/` is currently an empty untracked
directory. Under `nix build` it does not exist, so `libUtil.files.list` never returns it.
Under `getFlake "$PWD"` it does exist, gets returned as a directory entry, and the import
fails with `path '…/files/default.nix' does not exist`. `scheme-spec` sidesteps this by
taking `flake = self` as an argument and resolving the specs into a JSON file at build time;
the shell script only selects from it.
