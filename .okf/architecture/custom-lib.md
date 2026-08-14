---
type: Architecture Pattern
title: Custom lib
description: Files in `lib/` are auto-discovered by `lib/default.nix`, exposed as `flake.lib.*`, and injected into every module as `custom.lib`.
tags: [architecture, lib, convention]
generated:
  by: claude-code/claude-opus-4-8
  at: 2026-08-14T12:00:00Z
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
| `mkMixinModule.nix` | Per-mixin builder: declares `mixins.<prefix>.<name>.enable` + gates the body. Partially applied with `{ config, prefix }` by each tree's `mkDefaultMixinModule` aggregator helper and threaded to leaves; not called directly from the lib. See [mixin-pattern](mixin-pattern.md). |
| `mkLuaCall.nix` | Builds hyprland-style multi-arg lua callbacks. Used in `users/joker9944/hosts/HAL9000/default.nix` for hyprland `on = …`. |
| `lookupDesktopFiles.nix` | Names of the `.desktop` files a package provides. Reads `desktopItems` when the package declares them; the fallback reads `share/applications`, which builds the package during evaluation. |
| `requireDesktopFile.nix` | Asserts a package provides an entry and returns its ID, so a renamed entry fails the build. `name` defaults to the package name + `.desktop`, which is a guess — the assertion is what catches cases like `signal-desktop` → `signal.desktop`. Used by the hyprland binds, see [uwsm-session](uwsm-session.md). |
| `disko/` | Disk-layout template renderer. `custom.lib.disko.mkDiskoLayout { config, template ? templates.version1 }` renders a disko `devices` set from per-host params; templates live under `custom.lib.disko.templates.*`. Called from each `hosts/<host>/disks.nix` (which also imports `inputs.disko.nixosModules.disko` itself). |
| `obfuscation/` | XOR-based string obfuscation, exposed via the `obfuscate` app in `apps.nix`. |

Also present: small string / list / directory utilities (`indent`, `indentLines`, `mkCommand`, `mkIndentPrefix`, `first`, `last`, `nonNull`, `ls`). Names are self-descriptive; open `lib/` when you need one.

# Doc-strings

Public `lib/` functions carry an [RFC 145](https://github.com/NixOS/rfcs/blob/master/rfcs/0145-doc-strings.md) doc-comment: a `/** … */` block (note the **double asterisk** — a plain `/* … */` is *not* a doc-comment and the doc tooling skips it) placed immediately before the binding, with **CommonMark** content. Follow the nixdoc-conventional structure the existing helpers already use — a one-line summary, then `# Type` (a type signature), `# Arguments`, `# Example`:

    /**
      Build a NixOS configuration for a host.

      # Type

      ```
      mkNixosConfiguration :: { system, hostname, usernames, … } -> nixosConfiguration
      ```

      # Arguments

      - `hostname`: used to find modules at `hosts/<hostname>`

      # Example

      ```nix
      mkNixosConfiguration { system = "x86_64-linux"; hostname = "my-host"; usernames = [ … ]; }
      ```
    */

Those section headings are nixdoc convention, not mandated by the RFC (which fixes only the `/** */` outer format + CommonMark body), but keep them consistent across the tree. Exemplars: `lib/mkNixosConfiguration.nix`, `lib/mkHomeConfiguration.nix`, `lib/mkMixinModule.nix`, `lib/disko/mkDiskoLayout.nix`.

# Tests

Selected lib functions have pure tests under `tests/lib/`, wired into `flake.nix#checks.<system>.libTests`. Run them with `nix run .#test-lib`.

# Related

* [auto-discovery](auto-discovery.md) — the same pattern applied to mixin categories.
* [entry-points](entry-points.md) — where `custom.lib` gets injected.
