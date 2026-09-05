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

* The `services.k3s` mixin (`modules/nixos/mixins/services/k3s/default.nix`) imports `inputs.sops-nix.nixosModules.sops` (the first and only NixOS-side sops-nix use) and sets:
  ```nix
  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];   # host key → age identity
    secrets."k3s/token".sopsFile = ./secrets/k3s.yaml;        # nested path k3s.token
  };
  services.k3s.tokenFile = config.sops.secrets."k3s/token".path;
  ```
  Per-secret `sopsFile` rather than `defaultSopsFile`, which is host-global: a mixin setting it would claim the default for every other NixOS secret on that host, and two mixins setting it would conflict.
* The encrypted file lives inside the mixin at `modules/nixos/mixins/services/k3s/secrets/k3s.yaml` — see the `secrets/` exception in [module-layout](/architecture/module-layout.md).
* **Recipients** live in `.sops.yaml`. Each host's age recipient is derived from its `ssh_host_ed25519_key.pub` via `ssh-to-age`. `path_regex` is unanchored, so the path matches both the dedicated `secrets/k3s\.yaml$` rule and the general `secrets/*.yaml` one; the dedicated rule must sit **above** the general one, since sops applies the first match. Keeping it separate is what confines the cluster hosts to this one file.
* **Bootstrap order** (chicken/egg): a host can only decrypt after its SSH host key exists. So at rollout you provision the host key, append its `ssh-to-age` recipient to the dedicated rule, run `sops updatekeys modules/nixos/mixins/services/k3s/secrets/k3s.yaml`, then deploy. Until a host is added, the file is decryptable only by `joker9944`.
* **Encryption needs no private key** — re-wrapping encrypts to the recipient public keys in `.sops.yaml`. Only decryption (activation) needs a matching identity.

# What must not be committed

* Unencrypted secret material of any kind. cspell's `ignorePaths` (`.config/cspell.yaml`) lists `secrets.yaml` and `.sops.yaml`, which does *not* cover `k3s.yaml`; that is only a spellcheck tolerance either way — the safety comes from the files being sops-encrypted at rest.

# Related

* Inputs: `sops-nix` flake input, pinned to `github:Mic92/sops-nix/master`.
