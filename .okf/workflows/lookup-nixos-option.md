---
type: Playbook
title: Look up a NixOS option
description: Use the nixos-options Claude skill to query the pinned NixOS options.json before writing system config. Covers the three ways this differs from the home-manager lookup — search breadth, hidden renamed aliases, and third-party modules the dataset omits.
tags: [workflow, nixos, skill, agent]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-16T00:00:00Z
---

# Trigger

You are about to write a `services.*`, `boot.*`, `hardware.*`, `networking.*`, `virtualisation.*`, `security.*`, `users.*`, `fonts.*`, or `nix.settings.*` attribute under `hosts/` or `modules/nixos/` — or you're reviewing config that already assigns one.

# Tool

`nixos-options` — the system-level sibling of `hm-options`, same engine and subcommands (the surface is documented in `.claude/skills/nixos-options/SKILL.md`). It queries an `options.json` baked in at build time, so a query is `jq` rather than a flake evaluation.

The two datasets overlap in namespace (`programs.*`, `services.*` exist in both), so pick the tool by which tree you are editing, not by the attribute prefix. An empty result is a reason to try the sibling tool before concluding the option doesn't exist.

# What differs from the home-manager lookup

**Search is much noisier.** 24.5k options against home-manager's 5.4k, and 20.5k of them are under `services.*`. `search firewall` returns 764 lines. Add a second keyword — tokens are ANDed — or move to `list <prefix>` as soon as you know the namespace.

**A miss has two meanings.** nixpkgs keeps `mkRenamedOptionModule` aliases that still evaluate but are excluded from the docs JSON. `services.xserver.desktopManager.gnome.enable` is absent from the dataset yet still builds, because [`nixos/modules/services/desktop-managers/gnome.nix`](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/desktop-managers/gnome.nix) renames it. So a miss means "undocumented", not necessarily "broken" — but it does mean you should write the new spelling.

**Third-party modules are absent.** The dataset comes from `eval-config.nix` with `modules = [ ]`, so options from flake inputs — `disko.*` (used in `hosts/*/disks.nix`), `sops.*`, `home-manager.*` — are not in it. A miss there tells you nothing; read the input's own module source.

**`declarations` are bare path strings**, not the `{name, url}` objects home-manager emits, so there's no ready-made GitHub link. `example` is frequently absent too.

# Known hallucination traps

The skill's `SKILL.md` at `.claude/skills/nixos-options/SKILL.md` keeps the table — the 26.05 crop is dominated by two migrations: options moving out from under `services.xserver` as X11 stops being assumed, and daemon config collapsing into freeform `settings` attrsets that mirror upstream config-file key names. Update the table there when you hit a new one; it churns with each release.

# Where it pays off most

A [release upgrade](release-upgrade.md). The dataset tracks `flake.lock`, so after a bump it describes the release you're moving to while recall, the `nix` MCP server, and the wiki still describe the one you left. Reading module source doesn't resolve it — an upgrade has two trees in play and it's easy to read the wrong one. Mid-release the tool mostly saves time; mid-upgrade it's the only non-stale answer.

# Related

* [lookup-hm-option](lookup-hm-option.md) — the user-level counterpart.
* [release-upgrade](release-upgrade.md) — the bump procedure this is most valuable during.
* [add-mixin](add-mixin.md) — where these lookups get used.
* Tooling: `pkgs/nix-options/default.nix` builds both tools from one engine; dev shell wired in `flake.nix`. See [packages](/architecture/packages.md).
