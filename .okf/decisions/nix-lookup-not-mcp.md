---
type: Decision
title: Nix lookup answers from the pin, not from search.nixos.org
description: Package and option verdicts come from the revision `flake.lock` pins — `nix eval` and the two generated options datasets. search.nixos.org is demoted to name discovery, and the `mcp-nixos` MCP server is removed rather than kept as a second opinion.
tags: [decision, claude-code, nix, tooling]
generated:
  by: claude-code/claude-opus-5
  at: 2026-11-05T00:00:00Z
---

# The rule

Anything that answers "does this exist, at what version" reads the pinned revision. Packages:
`nix eval` on the flake's `nixpkgs` input, driven by the global `nix-packages` skill
(`modules/home/mixins/programs/claude-code/files/skills/nix-packages/`). Options: the generated
datasets behind `.claude/skills/{nixos,home-manager}-options`. search.nixos.org may suggest an
attribute *name*; it never supplies the verdict.

# Why the MCP server went

`programs.mcp.servers.nix` ran `mcp-nixos`, whose backend is search.nixos.org — an index of one
evaluated channel snapshot per platform. Three failure modes stack on an existence question:

* Whole package sets are absent. `pkgsStatic.busybox` evaluates to a version and returns zero
  search hits.
* The channel is not the lock. Default `nixos-unstable` against a `nixos-26.05` pin disagreed on
  `ripgrep` by a minor version.
* Ranking is fuzzy, so the exact attribute lands mid-list while the tool advertises "most relevant
  results at the end".

Each one reads as "not available" to a caller who trusts the tool. A false negative on existence is
worse than no tool, so the server is deleted rather than kept as a cross-check — a second opinion
that is confidently wrong does not get outvoted. `programs.mcp.servers` had no other entry, so the
`mcp` mixin went with it.

# Two traps the pinned route still has

Reading `flake.lock` by node name does not give this flake's nixpkgs: the node
spelled `nixpkgs` is a dependency's (`1c89083e`), while the root input resolves to
`nixpkgs_2` (`7dcdd87`). Both often agree on a package's version, so the wrong pin
reads as correct. `getFlake(…).inputs.nixpkgs` resolves the indirection.

`<attr>.version` is not an existence check either — `dockerTools` exists and
`dockerTools.version` raises `attribute 'version' missing`, the same words a truly
absent attribute produces. The skill's `scripts/nix-pkg` separates existence,
version, alias `throw` and absence structurally for that reason.

# Related

* [/architecture/mixin-pattern](/architecture/mixin-pattern.md) — the deleted `mcp` mixin was the
  cited canonical minimal example.
* [release-policy](release-policy.md) — why the pin and the current channel diverge at all.
