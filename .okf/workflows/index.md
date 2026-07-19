# Workflows

Playbooks for the concrete tasks that come up when working in this repo. Each one is short by design — the goal is to make the "how do I do X" answer discoverable, not to duplicate `nix` or `home-manager` documentation.

# Playbooks

* [rebuild](rebuild.md) — Rebuild the NixOS system or home-manager environment.
* [add-mixin](add-mixin.md) — Add a new home-manager or NixOS mixin the correct way.
* [lookup-hm-option](lookup-hm-option.md) — Use the home-manager-options skill to check an option before writing config.
* [secrets](secrets.md) — sops-nix layout, age keys, and how to add a new secret.
* [formatting-and-cspell](formatting-and-cspell.md) — What the pre-commit hooks enforce and how to whitelist technical words in the project dictionary.
