---
type: Playbook
title: Formatting and cspell
description: What the pre-commit hooks enforce (nixfmt, shfmt, flake8, ruff-format, conform on commit messages, …), why python is formatted at 79 columns, why cspell is deliberately NOT a hook (editor + on-demand only), and how to whitelist technical words.
tags: [workflow, formatting, spellcheck, pre-commit]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-05T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# Hook set

Defined in `flake.nix#checks.<system>.preCommitHooks.hooks`:

| Category | Hooks |
|---|---|
| Files | `trim-trailing-whitespace`, `end-of-file-fixer`, `fix-byte-order-marker`, `mixed-line-endings` (LF) |
| Nix | `deadnix`, `nil`, `nixfmt`, `statix` |
| Shell | `shellcheck`, `shfmt` |
| Python | `flake8`, `ruff-format` |
| Links | `rewrite-pr-links` (`.nix` and `.md`) |
| Git | `conform` (commit messages) |

Run everything at once: `nix fmt` (aliased to `pre-commit run --all-files`). Individual hooks fire automatically on `git commit`.

## conform gates commit messages

It runs at the **commit-msg** stage, so `nix fmt` and `nix flake check` never exercise it — only a real `git commit` does. Allowed types and scopes live in `.conform.yaml`; the scope list is closed and structural (the area of the repo, never the program), so an unlisted scope fails the commit. `Merge …` and `Revert "…"` messages aren't conventional commits and need `git commit --no-verify`.

## Python is linted by flake8 at 79 columns

flake8 rather than `ruff` as the linter, because nixpkgs' `writers.writePython3Bin` hardcodes
flake8 as its build-time check and runs it in a sandbox no project config can reach — so its
defaults are the only ones that can ever be satisfied. `ruff.toml` therefore sets
`line-length = 79` to match, and `ruff-format` stays as the formatter, flake8 having none.

That leaves exactly one rule the two cannot both satisfy: a black-style formatter puts space
around a slice colon when either side is an expression, and `E203` rejects it. It is turned off
in `settings.extendIgnore`. Nothing else needs an exception, which is the point — a
`writePython3Bin` call needs no `flakeIgnore` at all.

Neither tool rewraps prose, so an over-long docstring or comment is a manual fix.

# cspell is NOT a hook

cspell is deliberately **not** wired into pre-commit and **not** run in CI. It is entirely **editor + on-demand**:

* **Editor (live):** VS Code's cspell extension highlights as you type — open files only.
* **On-demand (project-wide):** the terminal sweep / VS Code task below, when you want the IntelliJ-style "all problems" view.

There is no `git commit` spelling gate. A misspelling never blocks a commit or a `nix flake check`.

# Formatters will rewrite your files

`nixfmt`, `shfmt`, and `ruff-format` modify files on commit. If a commit is blocked because "files were modified by this hook", re-stage and commit again — don't hand-format.

# Dictionaries

Two layers:

* **Shared technical dictionaries** live in a plain **writable clone at `~/Workspace/cspell-dicts`** (repo `Joker9944/cspell-dicts`) — *not* a git submodule. `.config/cspell.yaml` pulls them in with `import: ~/Workspace/cspell-dicts/cspell.yaml` (cspell expands `~`). Clone it once per machine (`git clone git@github.com:Joker9944/cspell-dicts.git ~/Workspace/cspell-dicts`); nothing manages that working tree declaratively, which is what keeps it writable for editor "add word".
* **Project dictionary** stays repo-local at `.config/dictionaries/project.txt` (one word per line, alphabetically-ish), declared in `.config/cspell.yaml`.

**Adding words:** for a broadly-useful technical term, add it from the editor — VS Code's cspell settings (in the `vscodium` mixin) point `cSpell.customDictionaries` at the shared clone's `user.txt` with `addWords`/`scope: user`, so "add to dictionary" writes there and `git push` shares it to every repo. For a genuinely project-specific term, use `project.txt`. Prefer either over an inline `# cSpell:ignore` comment (those exist in `flake.nix` only for flake-input-source URL terms).

# Project-wide check (no editor open-file limit)

The VS Code cspell extension only lints open files. For an IntelliJ-style "all problems" sweep:

* **Terminal:** `nix run .#cspell -- lint --no-progress "**"`.
* **Problems panel:** run the `cSpell: check project` task (`.vscode/tasks.json`) — its `problemMatcher` routes results into the Problems panel.

# Excludes

`shellcheck` skips files matching `^nx(\..+)?$` (the `nx` monorepo tooling). cspell has no pre-commit exclude (it's not a hook); its ignore list lives in `.config/cspell.yaml#ignorePaths` — `secrets.yaml`, `.sops.yaml`, `flake.lock`, `.gitignore`, `.idea`, `*.patch`, `/result`, `@girs`, `node_modules`, `nx*`.

# Related

* [rebuild](rebuild.md) — `nix flake check` runs these hooks too. cspell is not among them (not a hook).
* [architecture/comment-markers](/architecture/comment-markers.md) — the `cSpell:*` directives as one family among the repo's comment markers.
* [track-upstream-blockers](track-upstream-blockers.md) — what `rewrite-pr-links` is for; a hook change needs `nix develop .#preCommitHooks` before it takes effect locally.
* Repo dictionary: `.config/dictionaries/project.txt`. Shared dictionaries: `~/Workspace/cspell-dicts`.
