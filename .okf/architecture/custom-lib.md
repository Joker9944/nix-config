---
type: Architecture Pattern
title: Custom lib
description: Two libs — `lib/` for module-system helpers (`flake.lib.*`, `custom.lib`) and the `apps/util-lib` flake for general-purpose ones (`libUtil`). Both are directory-loaded by `mkLibNamespace`.
tags: [architecture, lib, convention]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-15T00:00:00Z
---

# Two libs

`lib/` holds helpers that only mean something to a module evaluation. General-purpose ones live in `apps/util-lib`, a flake of its own that exports `libUtil`. [/decisions/util-lib-split.md](/decisions/util-lib-split.md) has the boundary and the reasoning.

# The loader

`libUtil.mkLibNamespace { context, args }` reads a directory, skips `default.nix`, and imports every remaining entry with `args`. Files become attributes named after them; subdirectories become nested namespaces via their own `default.nix`, which is this one-liner at every depth:

```nix
{ libUtil, ... }@args:
libUtil.mkLibNamespace {
  context = ./.;
  inherit args;
}
```

Inside `apps/util-lib` it reads `libSelf.mkLibNamespace` instead, since that tree defines the loader it is loaded by. The flake bootstraps it with a direct `import ./lib/mkLibNamespace.nix`, so `apps/util-lib/lib/` has no root `default.nix`.

Each flake ties the fixed point exactly once, in its own `flake.nix`. The args thread down unchanged, so a leaf at any depth sees the whole tree — `lib/modules/mkMixinModule.nix` reaches a sibling as `libSelf.modules.mkConditionalModule`.

# Argument convention

A lib is injected into its own files as **`libSelf`**; a foreign lib arrives under its own name, **`libUtil`**. `flake` is the flake self — never `self`, which used to mean the lib and read backwards next to `flake`.

Consumers outside `lib/`:

| Where | Flake lib | libUtil |
|---|---|---|
| `hosts/`, `users/` mixin trees | `custom.lib` | `custom.libUtil` |
| `modules/`, `pkgs/` | `flake.lib` | `libUtil` (a direct arg) |

`custom.lib` is set by `mkNixosConfiguration` / `mkHomeConfiguration` in `specialArgs`; `custom.libUtil` rides along in the `custom` set built in `flake.nix`. `modules/` and `pkgs/` get `libUtil` passed in directly at their `importApply` / `import` site — this repo exports no `libUtil` flake output.

# What lives there

Notable helpers with non-obvious use:

| File | Purpose |
|---|---|
| `configuration/mkNixosConfiguration.nix` | Assembles a `nixosSystem`. See [entry-points](entry-points.md). |
| `configuration/mkHomeConfiguration.nix` | Assembles a standalone home-manager config. See [entry-points](entry-points.md). |
| `modules/mkDefaultModule.nix` | Auto-imports sibling files. See [auto-discovery](auto-discovery.md). |
| `modules/mkConditionalModule.nix` | Conditional module composition. |
| `modules/mkMixinModule.nix` | Per-mixin builder: declares `mixins.<prefix>.<name>.enable` + gates the body. Partially applied with `{ config, prefix }` by each tree's `mkDefaultMixinModule` aggregator helper and threaded to leaves; not called directly from the lib. See [mixin-pattern](mixin-pattern.md). |
| `modules/nonNull.nix` | `lib.mkIf (value != null) value`, so a null option is left unset rather than set to null. |
| `hyprland/mkLuaCall.nix` | Builds hyprland-style multi-arg lua callbacks. Used in `users/joker9944/hosts/HAL9000/default.nix` for hyprland `on = …`. |
| `lookupDesktopFiles.nix` | Names of the `.desktop` files a package provides. Reads `desktopItems` when the package declares them; the fallback reads `share/applications`, which builds the package during evaluation. |
| `requireDesktopFile.nix` | Asserts a package provides an entry and returns its ID, so a renamed entry fails the build. `name` defaults to the package name + `.desktop`, which is a guess — the assertion is what catches cases like `signal-desktop` → `signal.desktop`. Used by the hyprland binds, see [uwsm-session](uwsm-session.md). |
| `disko/` | Disk-layout template renderer. `custom.lib.disko.mkDiskoLayout { config, template ? templates.version1 }` renders a disko `devices` set from per-host params; templates live under `custom.lib.disko.templates.*` and are curried `lib` args first, then `{ config }`. Called from each `hosts/<host>/disks.nix` (which also imports `inputs.disko.nixosModules.disko` itself). |
| `obfuscation/` | XOR-based string obfuscation, exposed via the `obfuscate` app in `apps.nix`. Hand-written `default.nix`, not directory-loaded — splitting it would make its ASCII table public. |

`libUtil` holds the rest, in three namespaces: `strings` (`indent`, `indentLines`, `mkCommand`, `mkIndentPrefix`), `lists` (`first`, `last`), `files` (`list` — the directory scanner behind `mkDefaultModule` and `pkgs/default.nix`). Names are self-descriptive; open `apps/util-lib/lib/` when you need one.

# Doc-strings

Public functions in both libs carry an [RFC 145](https://github.com/NixOS/rfcs/blob/master/rfcs/0145-doc-strings.md) doc-comment: a `/** … */` block (note the **double asterisk** — a plain `/* … */` is *not* a doc-comment and the doc tooling skips it) placed immediately before the binding, with **CommonMark** content. Follow the nixdoc-conventional structure the existing helpers already use — a one-line summary, then `# Type` (a type signature), `# Arguments`, `# Example`:

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

Those section headings are nixdoc convention, not mandated by the RFC (which fixes only the `/** */` outer format + CommonMark body), but keep them consistent across the tree. Exemplars: `lib/configuration/mkNixosConfiguration.nix`, `lib/modules/mkMixinModule.nix`, `apps/util-lib/lib/mkLibNamespace.nix`.

# Tests

Each lib tests itself, with the same runner: pure `lib.runTests` suites in a `tests/lib/` directory, auto-collected and wired into that flake's `checks.<system>.libTests`. Run them with `nix run .#test-lib` — from the repo root for `lib/`, from `apps/util-lib` for `libUtil` (the app's `.#` is relative to the working directory).

# Related

* [auto-discovery](auto-discovery.md) — the same pattern applied to mixin categories.
* [entry-points](entry-points.md) — where `custom.lib` gets injected.
