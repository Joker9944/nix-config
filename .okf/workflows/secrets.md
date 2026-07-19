---
type: Playbook
title: Secrets with sops-nix
description: Per-user encrypted secrets.yaml files, decrypted at activation via sops-nix using an age key.
tags: [workflow, secrets, sops]
timestamp: 2026-07-17T00:00:00Z
---

# Layout

Each user owns `users/<username>/secrets.yaml`, encrypted with age. Both the NixOS and home-manager sides read from the same file:

* Home-manager side (`users/joker9944/default.nix`):
  ```nix
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };
  ```

* Age key on the target machine: `~/.config/sops/age/keys.txt`. Not in the repo — must be provisioned out-of-band before the first activation.

# Add a secret

1. Ensure `~/.config/sops/age/keys.txt` exists on your machine.
2. Ensure the recipients list in `.sops.yaml` includes your age public key.
3. `sops users/joker9944/secrets.yaml` — opens the encrypted file in your editor; sops re-encrypts on save.
4. Reference the secret in a module via `config.sops.secrets.<name>.path`.

# What must not be committed

* Unencrypted secret material of any kind. The pre-commit config's cspell `ignorePaths` includes `**/secrets.yaml` and `.sops.yaml` so those files don't get spellchecked, but that's a tolerance rule, not a safety guarantee — the safety comes from the files being sops-encrypted at rest.

# Related

* Inputs: `sops-nix` flake input, pinned to `github:Mic92/sops-nix/master`.
