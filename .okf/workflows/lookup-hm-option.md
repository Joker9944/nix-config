---
type: Playbook
title: Look up a home-manager option
description: Use the home-manager-options Claude skill to query the pinned home-manager options.json before writing config. Prevents hallucinated option names and short-circuits source-reading rabbit holes.
tags: [workflow, home-manager, skill, agent]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-16T00:00:00Z
---

# Trigger

A `programs.*`, `services.*`, `wayland.*`, `home.*`, `xdg.*`, `gtk.*`, `qt.*`, or `systemd.user.*` attribute is being written or reviewed — anything where the option name, type, or default could be misremembered.

# Tool

`hm-options`, on `PATH` from this repo's dev shell. It queries a home-manager `options.json` baked in at build time, so a lookup is `jq` rather than a flake evaluation, and the dataset tracks whatever `flake.lock` pins.

The subcommand surface, the query flow, and the release-churn rationale live in `.claude/skills/home-manager-options/SKILL.md`. That file is the authority and is maintained per home-manager release; a second copy here would drift against it.

The system-level sibling is [lookup-nixos-option](lookup-nixos-option.md) — same engine and subcommands over the NixOS dataset.

# Known hallucination traps

The `SKILL.md` keeps an evolving table of options models commonly misremember. It churns with each home-manager release, which is why it lives with the skill and is not mirrored here — a new trap belongs in that table.

# Related

* [add-mixin](add-mixin.md) — where the option lookups get used.
* [release-upgrade](release-upgrade.md) — the bump this is most valuable during; see [lookup-nixos-option](lookup-nixos-option.md#where-it-pays-off-most) for why.
* Skill source: `.claude/skills/home-manager-options/SKILL.md`.
* Tooling: `pkgs/nix-options/default.nix` (a package-group returning both tools via `mkOptionsTool`) with its engine at `pkgs/nix-options/files/nix-options.sh`; dev shell wired in `flake.nix`. See [packages](/architecture/packages.md).
