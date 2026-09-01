---
type: Architecture Pattern
title: Custom lib
description: Three libs — `lib/` for module-system helpers, `apps/util-lib` for general-purpose ones (`libUtil`), `apps/nix-schemes` for colour schemes (`libSchemes`). All directory-loaded by `mkLibNamespace`, all naming themselves `libSelf`. Plus how a scheme's non-standard keys are supplied and read.
tags: [architecture, lib, convention]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-31T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# Three libs

| Tree | Exported as | Holds |
|---|---|---|
| `lib/` | `flake.lib` | Helpers that only mean something to a module evaluation |
| `apps/util-lib/lib/` | `lib.libUtil` | General-purpose Nix helpers — `strings`, `lists`, `files`, `numbers` |
| `apps/nix-schemes/lib/` | `lib.libSchemes` | `color` (construction, conversion, WCAG metrics), `gtk`, `views`, `modules`, plus `generateScheme`, `mkScheme`, `types` and `init` at the root |

[/decisions/util-lib-split.md](/decisions/util-lib-split.md) has the boundary and the reasoning. All three load the same way, name themselves the same way, and nest under `lib.<name>` so a consumer's `inherit` reads the same as the tree's own arg — matching `inputs.nix-math.lib.math`.

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

`apps/nix-schemes/lib/init/` is the one deliberate second fixed point. `init` is a lib *constructor* (`pkgs -> libSchemes`), not a namespace: it re-loads its own directory with `pkgs` in scope and merges the result into the **root**, so `mkGtkThemeCss`, `mkIconTheme` and `mkCursorTheme` are top-level members of the returned lib rather than living under `.init`. It holds only what genuinely builds a derivation; everything reachable without `pkgs` — `generateScheme` included — sits in `lib/` proper.

# Argument convention

A lib is injected into its own files as **`libSelf`**; a foreign lib arrives under its own name — `libUtil`, `libSchemes`, `libMath`. That holds in *every* position, not just module arguments. `flake` is the flake self; `self` names nothing here. Why it works that way is in [decisions/util-lib-split](/decisions/util-lib-split.md).

Consumers outside `lib/`:

Every tree reaches both the same way: as static `importApply` arguments. `flake.nix#moduleArgs` binds `flake`, `inputs`, `libUtil` and `libMath`, and `mkModules` / `mkDefaultModule` thread that set down through each directory. `pkgs/` gets `libUtil` at its `import` site — this repo exports no `libUtil` flake output.

# What lives there

Notable helpers with non-obvious use:

| File | Purpose |
|---|---|
| `configuration/mkNixosConfiguration.nix` | Assembles a `nixosSystem`. See [entry-points](entry-points.md). |
| `configuration/mkHomeConfiguration.nix` | Assembles a standalone home-manager config. See [entry-points](entry-points.md). |
| `modules/mkDefaultModule.nix` | Auto-imports sibling files. See [auto-discovery](auto-discovery.md). |
| `modules/mkConditionalModule.nix` | Conditional module composition. |
| `modules/mkClassModule.nix` | Selects a module by the loading evaluation's `_class`. A class with no key is a no-op; a key naming no class throws. See [/decisions/dual-class-modules](/decisions/dual-class-modules.md). |
| `modules/mkMixinModule.nix` | Per-mixin builder: declares `mixins.<prefix>.<name>.enable` + gates the body. Partially applied with `{ config, prefix }` by each tree's `mkDefaultMixinModule` aggregator helper and threaded to leaves; not called directly from the lib. See [mixin-pattern](mixin-pattern.md). |
| `modules/nonNull.nix` | `lib.mkIf (value != null) value`, so a null option is left unset rather than set to null. |
| `hyprland/mkLuaCall.nix` | Builds hyprland-style multi-arg lua callbacks. Used in `users/joker9944/hosts/HAL9000/default.nix` for hyprland `on = …`. |
| `lookupDesktopFiles.nix` | Names of the `.desktop` files a package *declares* through `desktopItems`. A package that installs its entries any other way — most of them — yields `[ ]`, since the rest is only readable by building it. |
| `requireDesktopFile.nix` | Asserts a package provides an entry and returns its ID, so a renamed entry fails the build. `name` defaults to the package name + `.desktop`, which is a guess — the assertion is what catches cases like `signal-desktop` → `signal.desktop`. A declared entry is checked during evaluation; for anything else the returned ID carries a check derivation in its string context, which is why the function needs `pkgs` — see [/decisions/desktop-files-at-build-time](/decisions/desktop-files-at-build-time.md). Used by the hyprland binds, see [uwsm-session](uwsm-session.md). |
| `disko/` | Disk-layout template renderer. `flake.lib.disko.mkDiskoLayout { config, template ? templates.version1 }` renders a disko `devices` set from per-host params; templates live under `flake.lib.disko.templates.*` and are curried `lib` args first, then `{ config }`. Called from each `hosts/<host>/disks.nix` (which also imports `inputs.disko.nixosModules.disko` itself). |
| `obfuscation/` | XOR-based string obfuscation, exposed via the `obfuscate` app in `apps.nix`. Hand-written `default.nix`, not directory-loaded — splitting it would make its ASCII table public. |

`libSchemes.modules` holds one member, `mkVariantModules variants path`. It `importApply`s the same
template once per key of `variants`, passing the key and its value as `variant` and `displayName`, so
a module declaring `schemes.${variant}` and writing to `programs.${variant}` becomes a family with
one `enable` each — `schemes.firefox`/`librewolf`/`floorp` from `modules/home/firefox.nix`, four
editors from `modules/home/vscode/`. The variant map is both the list and the label source. It closes
over `flake`, which is why callers pass only two arguments.

`libUtil` holds the rest, in four namespaces: `strings` (`indent`, `indentLines`, `mkCommand`, `mkIndentPrefix`), `lists` (`first`, `last`), `files` (`list` — the directory scanner behind `mkDefaultModule`, `pkgs/default.nix` and the test runners), `numbers` (`clamp`, `toStringFloat`). Names are self-descriptive; open `apps/util-lib/lib/` when you need one.

# Scheme keys

A scheme is total: `meta`, `palette`, `accent`, `named`, `status` and `ansi` are computed for every
scheme, so a consumer reads one directly and the type declares them all
(`apps/nix-schemes/lib/types.nix`). `mkScheme` is the only constructor; the views under `lib/views/`
are pure `palette -> attrs` functions it calls. Why it is shaped that way, and where a colour that is
*not* app-independent belongs instead, is in [/decisions/scheme-model](/decisions/scheme-model.md).

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

Each lib tests itself, with the same runner: pure `lib.runTests` suites in a `tests/lib/` directory, collected with `libUtil.files.list` and wired into that flake's `checks.<system>.libTests`. Run them with `nix run .#test-lib` — from that flake's own directory, since the app's `.#` resolves against the working directory.

`apps/util-lib`'s own runner is the exception: it stays on raw `builtins.readDir`, so the harness never depends on the code under test.

# Related

* [auto-discovery](auto-discovery.md) — the same pattern applied to mixin categories.
* [entry-points](entry-points.md) — the constructors that assemble the trees these args reach.
