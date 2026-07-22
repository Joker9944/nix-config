---
type: Playbook
title: Look up a home-manager option
description: Use the home-manager-options Claude skill to query the pinned home-manager options.json before writing config. Prevents hallucinated option names and short-circuits source-reading rabbit holes.
tags: [workflow, home-manager, skill, agent]
timestamp: 2026-07-23T00:00:00Z
---

# Trigger

You are about to write a `programs.*`, `services.*`, `wayland.*`, `home.*`, `xdg.*`, `gtk.*`, `qt.*`, or `systemd.user.*` attribute — or you're reviewing config that already assigns one. Anything with a real risk that the option name, type, or default is misremembered.

# Why

Home-manager options get renamed and restructured between releases. Whatever revision `flake.lock` currently pins is not identical to what any given model's training data assumes. Guessing costs a rebuild cycle; looking up costs a shell call.

# Tool

`hm-options` — a binary on `PATH` from this repo's dev shell (defined in `flake.nix`, auto-loaded by `direnv`). It queries a pinned home-manager `options.json` — baked into the binary at build time — with `jq`, so there's no flake evaluation per call. Sibling `nixos-options` binary exists for NixOS options (built from the same engine); a dedicated skill for it is a future step.

| Command | Purpose |
|---|---|
| `hm-options path` | Print the resolved `options.json` store path. |
| `hm-options get <opt>` | Full record for one option (type, default, example, description, declarations). |
| `hm-options list <prefix>` | All option keys starting with `<prefix>`. |
| `hm-options search <keyword>` | Case-insensitive substring match across keys and descriptions. Multi-word queries treat every whitespace-separated token as an AND. |

# Typical flow

1. Broad search when you don't know the namespace: `hm-options search "gpg agent"`.
2. List the namespace once you spot it: `hm-options list services.gpg-agent`.
3. Get the specific option you plan to set: `hm-options get services.gpg-agent.enableSshSupport`.

Then write the module using the exact `type` and `default` from the record.

# Prefer this over reading source

If you're about to open a file under `<home-manager/modules/…>` or a nix-community/home-manager GitHub URL to look for an option, stop and use `hm-options` first. A `list` + `get` is two shell calls; the source file is often 500–2000 lines that will drown context.

The only reason to read module source is if you need to understand implementation logic the description doesn't cover.

# Known hallucination traps

The skill's own `SKILL.md` at `.claude/skills/home-manager-options/SKILL.md` keeps an evolving table of options that models commonly misremember (vscode's move to `programs.vscode.profiles.<name>`, direnv's `nix-direnv.enable`, and so on). When you hit a new one, update that table — don't mirror it here, since it churns with each home-manager release.

# Related

* [add-mixin](add-mixin.md) — where the option lookups get used.
* Skill source: `.claude/skills/home-manager-options/SKILL.md`.
* Tooling: `pkgs/nix-options/default.nix` (a package-group returning both tools via `mkOptionsTool`) with its engine at `pkgs/nix-options/files/nix-options.sh`; dev shell wired in `flake.nix`. See [packages](/architecture/packages.md).
