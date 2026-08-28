---
type: Decision
title: Vendored tinted-theming schemes
description: The 533 upstream scheme files are converted to Nix and committed under apps/nix-schemes/vendor/schemes, because reading YAML during evaluation needs either IFD or a Nix YAML parser, and neither is acceptable.
tags: [decision, nix-schemes, ifd, vendoring]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-21T00:00:00Z
---

# The rule

`apps/nix-schemes/vendor/schemes/<schemeSystem>/<schemeSlug>.nix` holds every upstream scheme as a plain attribute
set, mirroring both the layout and the full contents of `inputs.schemes` — so a handful carry `slug`
or `description` that nothing reads. `generateScheme` imports one and builds the colour objects;
nothing reads YAML at evaluation time.

`nix run .#update-schemes` regenerates the tree from the locked input with `yaml2nix`, one file at a
time; `inputs.schemes` stays an input solely to be that source. Its two globs are load-bearing:
`base*` skips upstream's `tinted8`, whose YAML has a different shape (nested `scheme:`,
`family`/`style` in place of `name`, named palette slots), and `*.yaml` skips the one stray `.yml`.

# Why not the alternatives

* **IFD** — the previous `fromYaml` ran `yaml2json` in a `runCommand` and read the result back, which
  serialises evaluation on a build and breaks eval-only consumers.
* **A pure-Nix YAML parser** — [SenchoPens/fromYaml](https://github.com/SenchoPens/fromYaml) hard-fails
  on 4 of the 533 files: a `description: |` block scalar, and space-indented comments. Both are its
  own documented TODOs, and its header disclaims reliability. One of the four is the Dracula scheme
  `modules/theme/dracula.nix` selects.
* **A scheme-specific parser** — parses all 533 correctly, but is another parser to own for data a
  scheduled job can convert once a month instead.

Vendoring removes the parsing problem from evaluation instead of solving it: the conversion still
parses YAML, but inside the regeneration app. Same move as `mkGtkThemeCss` in
[/reference/gtk-theming.md](/reference/gtk-theming.md).

Per-file rather than one blob so a regeneration diff shows *which* schemes changed. Loading a single
scheme is cheaper too, though by about a millisecond — not the reason.

# Staleness is scheduled, not detected

Nothing compares the vendored tree against `inputs.schemes`. `spec-0.11` is the upstream **default
branch** — the repository carries no tags — and it takes roughly 3.4 commits a month, 90% of them
touching `base16/` or `base24/`. Since `nix-flake-update.yaml` re-resolves that branch nightly, any
eval-time equality check would break every rebuild about three times a month.

So the tree is refreshed on a schedule instead: `nix-schemes-update.yaml` runs the app monthly and
opens a PR, and a month where upstream changed nothing produces no diff and therefore no PR. See
[/workflows/dependency-updates.md](/workflows/dependency-updates.md).

`tests/lib/generateScheme.nix` is the check that remains: it validates every vendored scheme's
`system`, `variant`, `name`, `author`, palette size and palette hex strings, so a malformed upstream
commit fails the monthly PR — the tree on `main` stays at the last good state rather than a rebuild
breaking later.

It asserts against the **raw** vendored data, not the constructed scheme, for two reasons. `fromHex`
is lazy per channel, so reading a scheme's `palette` attribute names never forces a colour and a bad
hex goes unnoticed. And when one *is* forced, `lib.fromHexString` fails inside `builtins.fromTOML` —
an error `tryEval` cannot catch, aborting the run without naming a scheme. Checking strings keeps
every failure reportable.

# Trade-off accepted

* **The tree may lag `inputs.schemes` by up to a month, and nothing reports the gap.** Deliberate —
  a new upstream scheme arriving late costs nothing, whereas detecting the gap costs a broken
  rebuild every time upstream pushes.
* **~320 KB of generated Nix in git.** A regeneration produces a large, mechanical diff.
* **The fetch is not saved.** Keeping `inputs.schemes` means the tarball is still fetched; it is what
  the app regenerates from, which keeps regeneration hermetic and offline.
* **A generated tree that must not be hand-edited.** Nothing enforces this; the next monthly run
  silently reverts any hand-edit.

# Related

* [/architecture/custom-lib.md](/architecture/custom-lib.md) — why `generateScheme` sits in `lib/`
  while `mkGtkThemeCss` stays under `init`.
