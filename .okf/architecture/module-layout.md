---
type: Architecture Pattern
title: Module layout — folders and files/
description: On-disk layout for any nix module in the repo — single file for trivial modules, `<name>/default.nix` folder once more than one file is involved, `files/` subdir for non-nix payloads.
tags: [architecture, modules, convention]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-16T00:00:00Z
---

# Scope

Applies to **any nix module in this repo**, not only mixins:

* Home-manager mixins under `users/mixins/`.
* NixOS mixins under `hosts/mixins/`.
* Flake-level modules under `modules/nixos/`, `modules/home/` and `modules/global/`.

Same rule everywhere: the two branches below decide the shape.

# `modules/global/` is class-agnostic

`modules/nixos/` and `modules/home/` are exported as `nixosModules.default` / `homeModules.default` and loaded into one tree each. `modules/global/` holds modules loaded into **both**, exported under their own key in each set (`{nixos,home}Modules.theme`) — the builders splat `lib.attrValues`, so each tree includes it exactly once and the two evaluations stay independent.

The constraint: such a module may only touch options that exist in both trees. Types are less restricted than they look — the module-arg `lib` carries `hm` only inside the home-manager tree, but `inputs.home-manager.lib.hm.{types,generators}` reaches both, so `fontType` is reusable (`hosts/mixins/desktop-environment/hyprland/regreet.nix` does the same with `toHyprconf`). What is *not* reusable is anything declared inline in a home-manager module rather than exported — `gtk.iconTheme` and `gtk.cursorTheme` have no `hm.types` equivalent and need a local submodule.

Such a module also has to *own* any third-party module it needs (`modules/global/theme/` is the sole importer of nix-schemes' `scheme` module), because importing the same non-path module value from two places declares its options twice.

What it cannot own is tree-specific wiring, so each tree gets a thin glue module beside it: `modules/{home,nixos}/theme.nix` import the nix-schemes renderers for their own tree (`gtk`/`librewolf`, `regreet`) and translate `custom.theme` into their options. Splitting an option's definitions across modules also splits their merge order — `programs.regreet.extraCss` is concatenated, so the fragment meant to win needs `lib.mkAfter`.

nix-schemes' contract forces that split: **a scheme carries no accent at origin** — a consumer adds one via `schemes.transformers` — so a nix-schemes *library* module must never read a transformer-added field, while a consumer may read what it supplied. `modules/global/theme/` is the consumer and contributes the accent transformer, resolving `schemes.scheme.accent` in both trees with no renderer module enabled.

Cross-tree data flows one way: `mkHomeConfiguration` builds from the NixOS configuration and passes `osConfig`, so home reads the host and never the reverse — see [entry-points](entry-points.md).

# Single file for trivial modules

A module that fits comfortably in one small `.nix` file lives directly in its parent directory (e.g., `hosts/mixins/services/maintenance.nix`, `users/mixins/programs/direnv.nix`). Nothing to expand until a second file shows up.

# Folder with `default.nix` when more than one file

As soon as a module needs more than a single `.nix` file, expand it into a folder:

```
<name>/
├── default.nix        # entrypoint — picked up by auto-discovery
├── <sibling>.nix      # additional nix files, imported explicitly from default.nix
└── …
```

[auto-discovery](auto-discovery.md) picks up `<name>/default.nix` as the module entry point; siblings are imported explicitly from within `default.nix`. Prevents the parent category directory from filling up with fragment files.

Real examples: `users/mixins/programs/vscodium/`, `users/mixins/desktop-environment/hyprland/*/`, `users/mixins/pwas/*/`.

# `files/` subdir for non-nix payloads

Non-nix files (patches, markdown context, dotfiles, static config) go in a `files/` subdirectory alongside `default.nix`, and are referenced from `default.nix` by relative path:

```
<name>/
├── default.nix
└── files/
    ├── CLAUDE.md      # referenced as ./files/CLAUDE.md
    └── some.patch     # referenced as ./files/some.patch
```

Keeps nix code separate from its data payload. Example: `users/mixins/programs/claude-code/files/CLAUDE.md`, consumed by `programs.claude-code.context`.

One exception: `users/mixins/programs/vscodium/openssh-no-checkperm.patch` sits at the module root rather than under `files/` — an inconsistency to avoid copying, not a template.

# Casing

Module files and directories are **kebab-case**; the mixin **option** they declare is **camelCase**. The filename is the kebab-case of the option name — `systemdBoot` ↔ `systemd-boot.nix`, `windowsSupport` ↔ `windows-support.nix`; single-word names coincide (`limine`). Digit escape: an option can't start with a digit, so `1password.nix` declares `_1password`.

`lib/` is the exception: a lib file is named for the **function it exports, in camelCase** — `mkDiskoLayout.nix` → `custom.lib.disko.mkDiskoLayout`, `mkNixosConfiguration.nix`, etc. Namespace subdirs stay lowercase and are the attribute path (`configuration/`, `disko/`, `hyprland/`, `modules/`, `obfuscation/`).

# Related

* [mixin-pattern](mixin-pattern.md) — the *shape* of mixin-style modules (options / config / enable flag); this concept covers *where the files go*.
* [auto-discovery](auto-discovery.md) — how `default.nix` gets picked up by the parent aggregator.
