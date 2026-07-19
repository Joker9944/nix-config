---
type: Architecture Pattern
title: Custom lib
description: Files in `lib/` are auto-discovered by `lib/default.nix`, exposed as `flake.lib.*`, and injected into every module as `custom.lib`.
tags: [architecture, lib, convention]
timestamp: 2026-07-17T00:00:00Z
---

# How it works

`lib/default.nix` reads its own directory, filters out `default.nix`, and imports each remaining file as an attribute. The imports receive the shared args `{ lib, inputs, flake, custom, self, … }`, where `self` is the fixed-point of the lib itself — so functions can refer to their siblings.

The resulting attrset is passed to `flake.nix#outputs.lib`, which becomes `self.lib.*`. Modules access it as `custom.lib` because `mkNixosConfiguration` and `mkHomeConfiguration` set `custom.lib = self` (the loaded lib) in `specialArgs`.

# What lives there

Notable helpers with non-obvious use:

| File | Purpose |
|---|---|
| `mkNixosConfiguration.nix` | Assembles a `nixosSystem`. See [entry-points](entry-points.md). |
| `mkHomeConfiguration.nix` | Assembles a standalone home-manager config. See [entry-points](entry-points.md). |
| `mkDefaultModule.nix` | Auto-imports sibling files. See [auto-discovery](auto-discovery.md). |
| `mkConditionalModule.nix` | Conditional module composition. |
| `mkLuaCall.nix` | Builds hyprland-style multi-arg lua callbacks. Used in `users/joker9944/hosts/HAL9000/default.nix` for hyprland `on = …`. |
| `lookupDesktopFiles.nix` | Finds `.desktop` files in a package. |
| `hyprland/` | Hyprland-specific config helpers. |
| `obfuscation/` | XOR-based string obfuscation, exposed via the `obfuscate` app in `apps.nix`. |

Also present: small string / list / directory utilities (`indent`, `indentLines`, `mkCommand`, `mkIndentPrefix`, `first`, `last`, `nonNull`, `ls`). Names are self-descriptive; open `lib/` when you need one.

# Tests

Selected lib functions have pure tests under `tests/lib/`, wired into `flake.nix#checks.<system>.libTests`. Run them with `nix run .#test-lib`.

# Related

* [auto-discovery](auto-discovery.md) — the same pattern applied to mixin categories.
* [entry-points](entry-points.md) — where `custom.lib` gets injected.
