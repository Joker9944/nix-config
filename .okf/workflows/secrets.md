---
type: Playbook
title: Secrets with sops-nix
description: Encrypted sops files decrypted at activation — per-user via an age key, or system-level keyed to a host's SSH host key.
tags: [workflow, secrets, sops]
generated:
  by: process:okf-migrate
  at: 2026-09-05T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# Layout

Each user owns `modules/home/users/<username>/secrets.yaml`, encrypted with age. Both the NixOS and home-manager sides read from the same file:

* Home-manager side (`modules/home/users/joker9944/default.nix`):
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
3. `sops modules/home/users/joker9944/secrets.yaml` — opens the encrypted file in your editor; sops re-encrypts on save.
4. Reference the secret in a module via `config.sops.secrets.<name>.path`.

# System-level secrets (NixOS side)

Some secrets must be decrypted at **system activation, before any login** — e.g. the k3s join token. These can't use the per-user age key (it lives in a user's home). Instead they're keyed to each host's **SSH host key**:

* The `services.k3s` mixin (`modules/nixos/mixins/services/k3s.nix`) imports `inputs.sops-nix.nixosModules.sops` (the first and only NixOS-side sops-nix use) and sets:
  ```nix
  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];   # host key → age identity
    defaultSopsFile = ../../../../secrets/k3s.yaml;
    secrets."k3s/token" = { };                                # nested path k3s.token
  };
  services.k3s.tokenFile = config.sops.secrets."k3s/token".path;
  ```
* **Recipients** live in `.sops.yaml`. Each host's age recipient is derived from its `ssh_host_ed25519_key.pub` via `ssh-to-age`. The `secrets/k3s.yaml` creation rule lists all cluster hosts + `joker9944`, and must sit **above** the general `secrets/*.yaml` rule — sops applies the first matching rule.
* **Bootstrap order** (chicken/egg): a host can only decrypt after its SSH host key exists. So at rollout you provision the host key, add its `ssh-to-age` recipient to `.sops.yaml`, re-encrypt `secrets/k3s.yaml`, then deploy. Until a host is added, the file is decryptable only by `joker9944`.
* **Encryption needs no private key** — `sops -e -i secrets/k3s.yaml` encrypts to the recipient public keys in `.sops.yaml`. Only decryption (activation) needs a matching identity.

# What must not be committed

* Unencrypted secret material of any kind. The pre-commit config's cspell `ignorePaths` includes `**/secrets.yaml` and `.sops.yaml` so those files don't get spellchecked, but that's a tolerance rule, not a safety guarantee — the safety comes from the files being sops-encrypted at rest.

# Related

* Inputs: `sops-nix` flake input, pinned to `github:Mic92/sops-nix/master`.
