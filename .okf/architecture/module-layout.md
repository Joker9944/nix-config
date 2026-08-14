---
type: Architecture Pattern
title: Module layout — folders and files/
description: On-disk layout for any nix module in the repo — single file for trivial modules, `<name>/default.nix` folder once more than one file is involved, `files/` subdir for non-nix payloads.
tags: [architecture, modules, convention]
generated:
  by: claude-code/claude-opus-4-8
  at: 2026-07-29T00:00:00Z
---

# Scope

Applies to **any nix module in this repo**, not only mixins:

* Home-manager mixins under `users/mixins/`.
* NixOS mixins under `hosts/mixins/`.
* Flake-level modules under `modules/nixos/` and `modules/home/`.

Same rule everywhere: the two branches below decide the shape.

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
