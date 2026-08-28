# Decisions

Load-bearing choices behind the shape of the repo. Consult before proposing structural changes — these encode the *why*, so future work stays coherent with the past.

# Decisions

* [standalone-home-manager](standalone-home-manager.md) — Home-manager runs as a separate flake output, not as a NixOS module.
* [enable-flag-mixins](enable-flag-mixins.md) — Every mixin exposes exactly one option (`enable`); knobs live in per-host overrides.
* [host-profiles](host-profiles.md) — One high-level profile per host; orthogonal roles are mixins, not a profile list; a profile must stay shared across machines.
* [release-policy](release-policy.md) — Track stable nixos in lockstep with matching home-manager; hyprland is the exception.
* [renovate-scope](renovate-scope.md) — Renovate covers GitHub Actions only; nix updates stay in workflows.
* [ci-identity](ci-identity.md) — CI commits are authored and signed as a GitHub App, not with a personal GPG key.
* [ci-nix-installer](ci-nix-installer.md) — CI installs Nix single-user with community actions; the cache is keyed on the lock files and seeded from `main`.
* [vendored-auto-upgrade](vendored-auto-upgrade.md) — The local `autoUpgrade` module displaces upstream's, which cannot upgrade from a remote flake ref.
* [util-lib-split](util-lib-split.md) — General-purpose helpers live in the `apps/util-lib` flake; `lib/` keeps what touches the module system. A lib names itself `libSelf`.
* [scheme-model](scheme-model.md) — A scheme is total and derived; user input enters as typed options, never as post-hoc mutation.
* [vendored-schemes](vendored-schemes.md) — Upstream schemes are converted to Nix and committed; a monthly job refreshes them, nothing checks them at eval time.
* [desktop-files-at-build-time](desktop-files-at-build-time.md) — Desktop-file contents are read by derivations, never during evaluation; `[Added Associations]` is not reproduced.
* [no-ifd](no-ifd.md) — `allow-import-from-derivation = false` on the machines and in CI; evaluation never builds.
