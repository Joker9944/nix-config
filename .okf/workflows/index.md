# Workflows

Playbooks for the concrete tasks that come up when working in this repo. Each one is short by design — the goal is to make the "how do I do X" answer discoverable, not to duplicate `nix` or `home-manager` documentation.

# Playbooks

* [rebuild](rebuild.md) — Rebuild the NixOS system or home-manager environment.
* [add-mixin](add-mixin.md) — Add a new home-manager or NixOS mixin the correct way.
* [lookup-hm-option](lookup-hm-option.md) — Use the home-manager-options skill to check a user-level option before writing config.
* [lookup-nixos-option](lookup-nixos-option.md) — The system-level counterpart, via the nixos-options skill.
* [secrets](secrets.md) — sops-nix layout, age keys, and how to add a new secret.
* [release-upgrade](release-upgrade.md) — track deferred "do at next release" changes via `UPGRADE(<release>)` markers; the release-bump steps.
* [track-upstream-blockers](track-upstream-blockers.md) — Find out whether the upstream bug a workaround waits on is still open, via `krank-tree`.
* [formatting-and-cspell](formatting-and-cspell.md) — What the pre-commit hooks enforce and how to whitelist technical words in the project dictionary.
* [dependency-updates](dependency-updates.md) — Which driver keeps each class of dependency current, and on what cadence.
