# Apps

`apps/` holds the sub-flakes this repo develops rather than consumes. Each locks separately and is
wired back in as a flake input — see [decisions/util-lib-split](/decisions/util-lib-split.md) for the
locking and naming rules they share.

# Applications

* [yas](yas.md) — the AGS v3 desktop shell: bar and notification popups, own flake, home-manager module.

The two library flakes are documented where they are used:
[architecture/custom-lib](/architecture/custom-lib.md) covers `apps/util-lib` (`libUtil`) and
`apps/nix-schemes` (`libSchemes`).
