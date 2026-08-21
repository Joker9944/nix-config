---
type: Decision
title: Evaluation never builds
description: '`allow-import-from-derivation = false` is set machine-wide by the nix mixin and in the CI `nix_conf`, so IFD fails loudly instead of relying on discipline.'
tags: [decision, ifd, nix, ci]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-21T00:00:00Z
---

# The rule

Nothing in this tree reads a derivation during evaluation, and two places enforce it rather than
trust discipline: `hosts/mixins/nix.nix` for the machines, and the `nix_conf` of
[ci-nix-installer](ci-nix-installer.md) for CI. CI is the gate — a runner never reads a host's
`/etc/nix/nix.conf`, so the machine setting only buys local feedback.

# Trade-off accepted

The machine setting governs every `nix` invocation on the box, not just this flake, and much of the
ecosystem imports from derivations by design (haskell.nix, poetry2nix, dream2nix). Recovery is
`--option allow-import-from-derivation true` on the one invocation that needs it, which works
without trusted-user status because the decision is made client-side during evaluation.

# Related

* [vendored-schemes](vendored-schemes.md) — YAML converted by a scheduled job instead of a `runCommand`.
* [desktop-files-at-build-time](desktop-files-at-build-time.md) — desktop-entry facts moved into derivations.
* [/reference/gtk-theming](/reference/gtk-theming.md) — generated CSS is `@import`ed by store path, never read back.
