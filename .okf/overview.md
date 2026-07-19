---
type: Repository
title: nix-config
description: Single-flake NixOS + standalone home-manager configuration organized around a two-level enable-flag mixin pattern.
resource: https://github.com/Joker9944/nix-config
tags: [nixos, home-manager, flake, root]
timestamp: 2026-07-17T00:00:00Z
---

# What this repo is

A personal NixOS + home-manager configuration organized around a two-level [mixin pattern](/architecture/mixin-pattern.md): every reusable module declares a single `enable` flag under `options.mixins.<category>.<name>`, and each host or user turns them on à la carte. Both the system and the user environment share this shape, so most of the repo maps 1:1 between the NixOS and home-manager sides.

Home-manager runs [standalone](/decisions/standalone-home-manager.md), not as a NixOS module — but both trees are constructed from a paired host record in `flake.nix` and share `pkgs`, overlays, and `custom.lib`.
