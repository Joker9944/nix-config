---
type: Architecture Pattern
title: Module layout — folders and files/
description: On-disk layout for any nix module in the repo — single file for trivial modules, `<name>/default.nix` folder once more than one file is involved, `files/` subdir for non-nix payloads, shell bodies over 400 characters extracted to `files/<name>.sh`, and a python payload taking `writePython3Bin` rather than a shell wrapper.
tags: [architecture, modules, convention]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-23T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
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

Such a module also has to *own* any third-party module it needs (`modules/global/theme/` is the sole importer of nix-schemes' `scheme`, `cursors` and `icons` modules), because importing the same non-path module value from two places declares its options twice.

What it cannot own is tree-specific wiring, so each tree gets a thin glue module beside it: `modules/{home,nixos}/theme.nix` import the nix-schemes renderers for their own tree (`gtk`/`librewolf`, `regreet`) and translate `custom.theme` into their options. Four constraints follow from that split:

* Splitting an option's definitions across modules splits their merge order too. `programs.regreet.extraCss` is concatenated, so the fragment meant to win needs `lib.mkAfter`.
* `fonts.fontconfig.defaultFonts.*` concatenates rather than conflicts, so each generic needs exactly one owner.
* `modules/home/theme.nix` claims `monospace` and `emoji` — the generics whose name is itself a classification — leaving `sansSerif` to `users/mixins/fonts.nix` as a content decision. Nothing sets `serif`.
* That binding sits in the home glue rather than the shared module deliberately: naming a font obliges the tree to install it, and the theme's Nerd Font is ~220 MiB the NixOS closure has no use for — nothing system-side resolves a generic, since regreet names its font outright.

nix-schemes' contract forces that split: **a scheme carries no accent at origin** — a consumer adds one via `schemes.transformers`. `modules/global/theme/` is that consumer, and contributes the accent transformer from a class-agnostic position so `schemes.scheme.accent` resolves in both trees with no renderer module enabled. Anything reading it back — library modules included — goes through `requireKey`, per [custom-lib](custom-lib.md).

Cross-tree data flows one way: `mkHomeConfiguration` builds from the NixOS configuration and passes `osConfig`, so home reads the host and never the reverse — see [entry-points](entry-points.md).

# Single file for trivial modules

A module that fits comfortably in one small `.nix` file lives directly in its parent directory (e.g., `hosts/mixins/services/maintenance.nix`, `users/mixins/programs/direnv.nix`). Nothing to expand until a second file shows up.

# Folder with `default.nix` when more than one file

As soon as a module needs more than a single `.nix` file, expand it into a folder:

```
<name>/
├── default.nix        # entrypoint — picked up by auto-discovery
├── <sibling>.nix      # a further module, or a data payload default.nix imports
└── …
```

[auto-discovery](auto-discovery.md) picks up `<name>/default.nix` as the module entry point. How a sibling is reached depends on what it is: a sibling **module** is auto-discovered when `default.nix` calls a `mkDefault*Module { dir = ./.; }` loader (`users/mixins/desktop-environment/hyprland/hyprlock/` picks up `styling.nix` this way), while a sibling that is a **value** — a settings or stylesheet fragment — is named explicitly, as `import ./settings.main.nix args`. Only `tmux/`, `waybar/` and `rofi/` take the second form. Either way the parent category directory stays free of fragment files.

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

# Shell bodies longer than 400 characters

A shell body handed to `writeShellApplication`, `writeShellScriptBin` or a systemd `script` stays
inline while it is short. Past **400 characters** it moves to `files/<name>.sh` and is read back:

```nix
text = builtins.readFile ./files/update-schemes.sh;
```

Shell inside a nix string gets no syntax highlighting, is never touched by `shfmt`, and needs
`''${…}` for every shell expansion. A `.sh` file gets all three back, plus the `shellcheck` hook —
which systemd bodies and `writeShellScriptBin` otherwise never see, since only
`writeShellApplication` shellchecks at build time.

The cost is that nix values can no longer be interpolated into the script. Hand them over as
environment variables — `runtimeEnv` on `writeShellApplication` (`apps/nix-schemes/apps/default.nix`),
which keeps `text` a bare `readFile`; `replaceVars` where there is no such argument.
`pkgs/nix-options/default.nix` instead concatenates an assignment ahead of the file, which puts shell
back into a nix string — not the form to copy.

The hook lints the file standalone, with no knowledge that the wrapper sets `errexit` — so a bare
`cd` needs an explicit `|| exit` that would be redundant inline.

## A python payload is not a shell body

An app whose work is python takes no wrapper at all. `pkgs.writers.writePython3Bin` reads the file
with `readFile`, so the hooks still reach it, and covers what `writeShellApplication` was wanted
for: `libraries` for imports, and `makeWrapperArgs` — undocumented but passed straight through
(`build-support/writers/scripts.nix:97`) — for the rest. `--prefix PATH` for a tool reached through
`subprocess`, `--add-flags` to prefill an argument the caller does not choose. Both cursor apps in
`apps/nix-schemes/apps/default.nix` are the worked example.

The writer supplies the interpreter line, so such a file carries **no shebang** of its own; it would
land on line 2 and fail the writer's flake8 as `E265`. A script a derivation runs as
`python3 <path>` instead — `mkCursorTheme/build.py`, `mkIconTheme/recolour.py` — keeps one.

# `git` is ambient, not a `runtimeInput`

A script that shells out to `git` does **not** list it in `runtimeInputs` — `inheritPath` is on by
default, so it gets the caller's git: nixpkgs' on a dev machine, the runner's in CI. Anything
operating on a working copy already presupposes git, and pinning a second copy into the closure
buys nothing the ambient one doesn't already do better, since the repo, its config and its hooks are
ambient regardless. `apps.nix#krank-tree` and `apps/nix-schemes#update-schemes` both rely on this.

Two boundaries. This is an argument about `git` specifically, from it being a precondition for the
repo existing — every other tool still gets declared. And it does not hold under systemd, where the
unit's PATH is minimal; a service that shells out to `git` must pin it.

# Casing

Module files and directories are **kebab-case**; the mixin **option** they declare is **camelCase**. The filename is the kebab-case of the option name — `systemdBoot` ↔ `systemd-boot.nix`, `windowsSupport` ↔ `windows-support.nix`; single-word names coincide (`limine`). Digit escape: an option can't start with a digit, so `1password.nix` declares `_1password`.

`lib/` is the exception: a lib file is named for the **function it exports, in camelCase** — `mkDiskoLayout.nix` → `custom.lib.disko.mkDiskoLayout`, `mkNixosConfiguration.nix`, etc. Namespace subdirs stay lowercase and are the attribute path (`configuration/`, `disko/`, `hyprland/`, `modules/`, `obfuscation/`).

# Related

* [mixin-pattern](mixin-pattern.md) — the *shape* of mixin-style modules (options / config / enable flag); this concept covers *where the files go*.
* [auto-discovery](auto-discovery.md) — how `default.nix` gets picked up by the parent aggregator.
* [/workflows/formatting-and-cspell](/workflows/formatting-and-cspell.md) — the `shellcheck` and `shfmt` hooks an extracted `.sh` file becomes subject to.
