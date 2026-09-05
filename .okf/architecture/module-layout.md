---
type: Architecture Pattern
title: Module layout — folders and files/
description: On-disk layout for any nix module in the repo — single file for trivial modules, `<name>/default.nix` folder once more than one file is involved, `files/` subdir for non-nix payloads, shell bodies over 400 characters extracted to `files/<name>.sh`, and a python payload taking `writePython3Bin` rather than a shell wrapper.
tags: [architecture, modules, convention]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-05T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# Scope

Applies to **any nix module in this repo**, not only mixins:

* Home-manager mixins under `modules/home/mixins/`.
* NixOS mixins under `modules/nixos/mixins/`.
* Every other module directory under `modules/`.

Same rule everywhere: the two branches below decide the shape.

# `modules/` — class trees and features

`modules/nixos/` and `modules/home/` each hold one tree's modules, in subtrees the flake exports
under distinct keys: `mixins` (one aggregated module via `importApply`), plus `mkModules`-collected
flat keys — `hosts-*` / `profiles-*` / `users-*` / `public-*` on the NixOS side, `users-*` /
`public-*` on the home side (see
[auto-discovery](auto-discovery.md#the-flake-level-collector-mkmodules)). The
[entry-point](entry-points.md) constructors select the per-host and per-user keys and inject every
`public-*` module wholesale.

Any other directory under `modules/` is a **feature** exported under its own key in *both* sets —
`modules/theme/` is `{nixos,home}Modules.theme`. A feature is one module value both trees load, so
its tree-specific half selects itself with `flake.lib.modules.mkClassModule` on the `_class` module
argument — see [/decisions/dual-class-modules](/decisions/dual-class-modules.md). `modules/theme/`
is the worked example: `default.nix` carries what both trees share; the auto-discovered sibling
`compat.nix` holds the per-tree halves behind `mkClassModule`.

Everything outside `compat.nix`'s class branches may only touch options that exist in both trees.
Types are less restricted than they look — the module-arg `lib` carries `hm` only inside the
home-manager tree, but `inputs.home-manager.lib.hm.{types,generators}` reaches both, so `fontType`
is reusable (`modules/nixos/mixins/desktop-environment/hyprland/regreet.nix` does the same with
`toHyprconf`). What is *not* reusable is anything declared inline in a home-manager module rather
than exported — `gtk.iconTheme` and `gtk.cursorTheme` have no `hm.types` equivalent and need a local
submodule.

Nor may it import a third-party module that both trees also reach another way: importing the same
non-path module value from two places declares its options twice. nix-schemes' class-agnostic
`scheme`, `cursors` and `icons` ride along in both of its `<class>Modules.default` bundles, which
`compat.nix` imports one of per class branch — their only importers here — and
`modules/theme/default.nix` imports nothing.

# The theme's per-tree halves (`compat.nix`)

Each `mkClassModule` branch of `modules/theme/compat.nix` imports the matching nix-schemes bundle
(`<class>Modules.default`) and translates `custom.theme` into `schemes.*` options. Constraints that
follow from the halves being modules separate from everything else that writes the same options:

* Splitting an option's definitions across modules splits their merge order too. `programs.regreet.extraCss` is concatenated, so the fragment meant to win carries `lib.mkAfter` (`modules/nixos/mixins/desktop-environment/hyprland/regreet.nix`).
* `fonts.fontconfig.defaultFonts.*` concatenates rather than conflicts, so each generic needs exactly one owner.
* The `homeManager` branch claims `monospace` and `emoji` — the generics whose name is itself a classification — leaving `sansSerif` to `modules/home/mixins/fonts.nix` as a content decision. Nothing sets `serif`.
* That binding sits in the home branch rather than the shared body deliberately: naming a font obliges the tree to install it, and the theme's Nerd Font is ~220 MiB the NixOS closure has no use for — nothing system-side resolves a generic, since regreet names its font outright.

nix-schemes' contract forces that split: the scheme carries the accent, but only
`modules/theme/default.nix` knows what it should be. It sets `schemes.accent` from a class-agnostic
position, so `schemes.scheme.accent` resolves in both trees with no renderer module enabled; the
class branches translate the GTK-only half of `custom.theme.gtk` into `schemes.{gtk,regreet}`.

# Picking a theme

A theme is selected by `custom.themes.<name>.enable`, declared per leaf by a local `mkThemeModule` in
`modules/theme/default.nix` — deliberately *not* `mkMixinModule`, since a theme is a
mutually-exclusive selection rather than an à-la-carte capability. `modules/nixos/profiles/desktop.nix`
holds the selection and `modules/home/users/joker9944/default.nix` mirrors it with
`custom.themes = osConfig.custom.themes`.

There is **no assertion** on that exclusivity, and adding one would be dead code: every theme defines
`schemes.source`, a single `attrTag`, so two enabled themes already fail the module merge with an
error naming both files — and a merge error precedes assertion checking. Enabling *none* is the weak
spot: the failure is a `schemes.librewolf.scheme` type error on `null`, several modules away from the
cause, which is why the selection sits in the profile rather than per-host.

Cross-tree data flows one way: `mkHomeConfiguration` builds from the NixOS configuration and passes
`osConfig`, so home reads the host and never the reverse — see [entry-points](entry-points.md).

# Single file for trivial modules

A module that fits comfortably in one small `.nix` file lives directly in its parent directory (e.g., `modules/nixos/mixins/services/maintenance.nix`, `modules/home/mixins/programs/direnv.nix`). Nothing to expand until a second file shows up.

# Folder with `default.nix` when more than one file

As soon as a module needs more than a single `.nix` file, expand it into a folder:

```
<name>/
├── default.nix        # entrypoint — picked up by auto-discovery
├── <sibling>.nix      # a further module, or a data payload default.nix imports
└── …
```

[auto-discovery](auto-discovery.md) picks up `<name>/default.nix` as the module entry point. How a sibling is reached depends on what it is: a sibling **module** is auto-discovered when `default.nix` calls a `mkDefault*Module { dir = ./.; }` loader (`modules/home/mixins/desktop-environment/hyprland/hyprlock/` picks up `styling.nix` this way), while a sibling that is a **value** — a settings or stylesheet fragment — is named explicitly, as `import ./theme.rasi.nix args`. Only `rofi/` takes the second form. Either way the parent category directory stays free of fragment files.

Real examples: `modules/home/mixins/programs/vscodium/`, `modules/home/mixins/desktop-environment/hyprland/*/`, `modules/home/mixins/pwas/*/`.

# `files/` subdir for non-nix payloads

Non-nix files (patches, markdown context, dotfiles, static config) go in a `files/` subdirectory alongside `default.nix`, and are referenced from `default.nix` by relative path:

```
<name>/
├── default.nix
└── files/
    ├── CLAUDE.md      # referenced as ./files/CLAUDE.md
    └── some.patch     # referenced as ./files/some.patch
```

Keeps nix code separate from its data payload. Example: `modules/home/mixins/programs/claude-code/files/CLAUDE.md`, consumed by `programs.claude-code.context`.

One exception: `modules/home/mixins/programs/vscodium/openssh-no-checkperm.patch` sits at the module root rather than under `files/` — an inconsistency to avoid copying, not a template.

Sops-encrypted payloads are the one deliberate departure: they go in `secrets/`, not `files/`, because `.sops.yaml` `creation_rules` match on path and the repo's rules key off a `secrets/` parent directory. `modules/nixos/mixins/services/k3s/secrets/k3s.yaml` is the instance — see [secrets](/workflows/secrets.md).

Either way the payload directory must sit inside a *leaf* module folder. A category aggregator imports **every** entry in its directory (`mkDefaultModule`, `lib/modules/mkDefaultModule.nix`), so a bare `secrets/` or `files/` dir beside a category's `.nix` files is imported as a module and eval fails on the missing `default.nix`.

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

`lib/` is the exception: a lib file is named for the **function it exports, in camelCase** — `mkDiskoLayout.nix` → `flake.lib.disko.mkDiskoLayout`, `mkNixosConfiguration.nix`, etc. Namespace subdirs stay lowercase and are the attribute path (`configuration/`, `disko/`, `hyprland/`, `modules/`, `obfuscation/`).

# Related

* [mixin-pattern](mixin-pattern.md) — the *shape* of mixin-style modules (options / config / enable flag); this concept covers *where the files go*.
* [auto-discovery](auto-discovery.md) — how `default.nix` gets picked up by the parent aggregator.
* [/workflows/formatting-and-cspell](/workflows/formatting-and-cspell.md) — the `shellcheck` and `shfmt` hooks an extracted `.sh` file becomes subject to.
