---
type: Playbook
title: Formatting and cspell
description: What the pre-commit hooks enforce (nixfmt, shfmt, ruff, …), why cspell is deliberately NOT a hook (editor + on-demand only), and how to whitelist technical words.
tags: [workflow, formatting, spellcheck, pre-commit]
generated:
  by: process:okf-migrate
  at: 2026-07-29T00:00:00Z
---

# Hook set

Defined in `flake.nix#checks.<system>.preCommitHooks.hooks`:

| Category | Hooks |
|---|---|
| Files | `trim-trailing-whitespace`, `end-of-file-fixer`, `fix-byte-order-marker`, `mixed-line-endings` (LF) |
| Nix | `deadnix`, `nil`, `nixfmt`, `statix` |
| Shell | `shellcheck`, `shfmt` |
| Python | `ruff`, `ruff-format` |

Run everything at once: `nix fmt` (aliased to `pre-commit run --all-files`). Individual hooks fire automatically on `git commit`.

# cspell is NOT a hook

cspell is deliberately **not** wired into pre-commit and **not** run in CI. It is entirely **editor + on-demand**:

* **Editor (live):** VS Code's cspell extension highlights as you type — open files only.
* **On-demand (project-wide):** the terminal sweep / VS Code task below, when you want the IntelliJ-style "all problems" view.

There is no `git commit` spelling gate. A misspelling never blocks a commit or a `nix flake check`. (This replaced an earlier hard-fail all-files hook, and a briefly-considered local-only hook wrapper — both dropped as over-engineered for a personal aid.)

# Formatters will rewrite your files

`nixfmt`, `shfmt`, and `ruff-format` modify files on commit. If a commit is blocked because "files were modified by this hook", re-stage and commit again — don't hand-format.

# Dictionaries

Two layers:

* **Shared technical dictionaries** live in a plain **writable clone at `~/Workspace/cspell-dicts`** (repo `Joker9944/cspell-dicts`) — *not* a git submodule anymore. `.config/cspell.yaml` pulls them in with `import: ~/Workspace/cspell-dicts/cspell.yaml` (cspell expands `~`). Clone it once per machine (`git clone git@github.com:Joker9944/cspell-dicts.git ~/Workspace/cspell-dicts`); nothing manages that working tree declaratively, which is what keeps it writable for editor "add word".
* **Project dictionary** stays repo-local at `.config/dictionaries/project.txt` (one word per line, alphabetically-ish), declared in `.config/cspell.yaml`.

**Adding words:** for a broadly-useful technical term, add it from the editor — VS Code's cspell settings (in the `vscodium` mixin) point `cSpell.customDictionaries` at the shared clone's `user.txt` with `addWords`/`scope: user`, so "add to dictionary" writes there and `git push` shares it to every repo. For a genuinely project-specific term, use `project.txt`. Prefer either over an inline `# cSpell:ignore` comment (those exist in `flake.nix` only for flake-input-source URL terms).

# Project-wide check (no editor open-file limit)

The VS Code cspell extension only lints open files. For an IntelliJ-style "all problems" sweep:

* **Terminal:** `nix run .#cspell -- lint --no-progress "**"`.
* **Problems panel:** run the `cSpell: check project` task (`.vscode/tasks.json`) — its `problemMatcher` routes results into the Problems panel.

# Excludes

`shellcheck` skips files matching `^nx(\..+)?$` (the `nx` monorepo tooling). cspell has no pre-commit exclude anymore (it's not a hook); its ignore list lives in `.config/cspell.yaml#ignorePaths` — `secrets.yaml`, `.sops.yaml`, `flake.lock`, `.gitignore`, `.idea`, `*.patch`, `/result`, `@girs`, `node_modules`, `nx*`.

# Related

* [rebuild](rebuild.md) — `nix flake check` runs these hooks too. cspell is not among them (not a hook).
* Repo dictionary: `.config/dictionaries/project.txt`. Shared dictionaries: `~/Workspace/cspell-dicts`.
