---
type: Playbook
title: Formatting and cspell
description: What the pre-commit hooks enforce (nixfmt, shfmt, ruff, cspell, …) and how to whitelist technical words in the project dictionary.
tags: [workflow, formatting, spellcheck, pre-commit]
timestamp: 2026-07-17T00:00:00Z
---

# Hook set

Defined in `flake.nix#checks.<system>.preCommitHooks.hooks`:

| Category | Hooks |
|---|---|
| Files | `trim-trailing-whitespace`, `end-of-file-fixer`, `fix-byte-order-marker`, `mixed-line-endings` (LF) |
| General | `cspell` |
| Nix | `deadnix`, `nil`, `nixfmt`, `statix` |
| Shell | `shellcheck`, `shfmt` |
| Python | `ruff`, `ruff-format` |

Run everything at once: `nix fmt` (aliased to `pre-commit run --all-files`). Individual hooks fire automatically on `git commit`.

# Formatters will rewrite your files

`nixfmt`, `shfmt`, and `ruff-format` modify files on commit. If a commit is blocked because "files were modified by this hook", re-stage and commit again — don't hand-format.

# cspell dictionary

Project dictionary lives at `.config/dictionaries/project.txt` (one word per line, alphabetically-ish sorted). Config is at `.config/cspell.yaml`.

**When cspell flags a legitimate technical word, add it to `project.txt` rather than adding an inline `# cSpell:ignore` comment.** Inline comments do exist in `flake.nix` for flake-input-source terms (they'd otherwise sit in the dictionary purely to satisfy the URL), but the dictionary is the primary approach for anything that appears in ordinary code — nix jargon (`attrset`, `pkgs`), shell keywords (`esac`, `pipefail`), jq operators (`gsub`, `startswith`), real package/extension names.

# Excludes

`cspell` and `shellcheck` both skip files matching `^nx(\..+)?$` (the `nx` monorepo tooling). `cspell` also ignores `**/secrets.yaml`, `.sops.yaml`, `flake.lock`, `.gitignore`, `.idea`, `*.patch`, and `/result`.

# Related

* [rebuild](rebuild.md) — `nix flake check` runs these hooks too.
* Dictionary file: `.config/dictionaries/project.txt`.
