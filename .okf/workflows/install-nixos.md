---
type: Playbook
title: Install NixOS on a new machine
description: Declare a host, harvest its hardware facts from the live installer, seed its SSH host key and user password hash, then install once with nixos-anywhere.
tags: [workflow, install, nixos, disko, sops]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-07T00:00:00Z
---

# Trigger

A machine exists that should become one of this flake's `nixosConfigurations`.

The hardware facts a host needs — kernel modules, the OS disk's device name — can only come from the machine. They are read out of the **live installer**, so the machine is installed exactly once. Nothing here requires a throwaway install first.

# Prerequisites

* Target booted on the stock NixOS **minimal** ISO for the host's architecture. Nothing custom is needed: the ISO is only a runtime, and its channel need not match this flake's nixpkgs.
* A password on the target. sshd already runs on the installer (`profiles/installation-device.nix` sets `services.openssh.enable` and `PermitRootLogin = "yes"`), but `nixos` and `root` both ship with *empty* passwords and sshd refuses those. The console autologins as `nixos` with passwordless sudo, so `passwd` on the console is the whole step — or drop a key into `~/.ssh/authorized_keys` instead.
* `sops`, `ssh-to-age` and `mkpasswd` on `PATH` — all three are in the dev shell.
* The target's IP, from `ip -brief addr` on the console.

# 1. Declare the host

Add the record to the `nixosConfigurations` list in `flake.nix`, and create `modules/nixos/hosts/<name>/` with `default.nix`, `mixins.nix` and `disks.nix`. [entry-points](/architecture/entry-points.md) covers what each key selects; copy the closest existing host.

Every file in that directory is `importApply`-ed with static args, so each one is **two-layer**: an outer argument for the static args, then the module. Drop the inner layer when the body needs no module args, never the outer — `_: { … }` is the minimum.

# 2. Harvest the hardware facts

One session yields both unknowns:

```bash
ssh nixos@<ip> lsblk
ssh nixos@<ip> 'sudo nixos-generate-config --show-hardware-config --no-filesystems' \
  > modules/nixos/hosts/<name>/hardware-configuration.nix
```

`--show-hardware-config` prints to stdout instead of writing a tree under `/mnt/etc/nixos`; `--no-filesystems` omits `fileSystems`, which disko owns. Use `lsblk` output to fill the disk `name` in `disks.nix`.

Then prepend `_:` to the generated file (step 1) and `git add` it — see the flake-visibility gotcha below.

# 3. Build the seed tree

`seed/` is extracted into the target's root before its first activation. It carries what must already be on disk when NixOS runs: the host's SSH key, and the user's password hash. It holds private material, is gitignored, and should be deleted once the host is up.

## Host key and sops recipient

System secrets are decrypted at activation against the host's SSH host key, so that key must exist and be a known sops recipient *before* the first activation. Generating it up front is what collapses the chicken-and-egg into a single install; [secrets](secrets.md) covers the mechanism.

```bash
install -d -m755 seed/etc/ssh
ssh-keygen -t ed25519 -N "" -C <name> -f seed/etc/ssh/ssh_host_ed25519_key
chmod 600 seed/etc/ssh/ssh_host_ed25519_key
ssh-to-age -i seed/etc/ssh/ssh_host_ed25519_key.pub
```

Append the printed `age1…` recipient to the matching creation rule in `.sops.yaml`, re-wrap each secret the host must read, and commit:

```bash
sops updatekeys modules/nixos/mixins/services/k3s/secrets/k3s.yaml
```

## User password

`users.users.joker9944.hashedPasswordFile` reads `/etc/passwd-hash/joker9944`, which only the seed supplies — no hash is committed. Skip this and the account is created locked, which on a server mixin is unrecoverable remotely: sshd rejects both passwords and root, so nothing can `sudo` and only a console gets you back in.

```bash
install -d -m700 seed/etc/passwd-hash
mkpasswd -m yescrypt > seed/etc/passwd-hash/joker9944
chmod 600 seed/etc/passwd-hash/joker9944
```

`mkpasswd` prompts, so the password never reaches shell history.

# 4. Install

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#<name> --target-host nixos@<ip> --extra-files ./seed
```

`--extra-files` ships the tree as `tar -cpf-` and extracts it at `/mnt` with `--no-same-owner`, so modes survive and the key lands root-owned.

`--build-on` defaults to `auto`, which resolves to `local` whenever the build and target systems match — always the case here, so the workstation builds the closure and ships it over the LAN rather than having the target re-fetch it from the cache.

The default phases are `kexec,disko,install,reboot`; kexec is what lets nixos-anywhere take over an arbitrary running Linux. Booting the NixOS installer makes it redundant, and it is skipped automatically — the target reports `isInstaller=y` and `runKexec` returns early. No `--phases` argument is needed.

# 5. Verify

```bash
ssh <name> systemctl status sops-install-secrets   # secret decrypted at activation
ssh <name> systemctl --failed
```

# Gotchas

* **Untracked files are invisible to a git flake.** A freshly generated `hardware-configuration.nix` that is not `git add`-ed does not exist as far as `nix build` is concerned — the build silently uses the old tree, or fails on the missing import. `git add` before every install or rebuild.
* **The outer module layer.** A stock `nixos-generate-config` file starts `{ config, lib, modulesPath, ... }:`, which `importApply` would feed the *static* args. Without a `_:` in front it fails with `attempt to call something which is not a function but a set`.
* **`--vm-test` cannot validate these layouts.** disko's test harness hardcodes 4 GB disk images (`lib/tests.nix`, `emptyDiskImages`) with no knob to raise it, so any layout here fails partitioning in the VM regardless of correctness. Not a signal.
* **`hashedPasswordFile` is an *initial* password here.** `users.mutableUsers` is `true`, and `update-users-groups.pl` overwrites an existing `/etc/shadow` entry only when it is `false`. So the seeded hash lands only at account creation, `passwd` afterwards wins permanently, and the file cannot repair a host that is already installed. A missing file is a warning, not a build failure.
* **`nixos-anywhere --generate-hardware-config`** does the same harvest (its backend runs the identical `nixos-generate-config --show-hardware-config --no-filesystems`) and can write the file for you. It still needs the `_:` prepended and `git add`-ed before the build can see it, which is why step 2 does it explicitly.

# Related

* [secrets](secrets.md) — why the host key is the identity, and how recipients are managed.
* [rebuild](rebuild.md) — the loop after the machine is up.
* [architecture/entry-points](/architecture/entry-points.md) — what a host record assembles.
* [nyx-bootstrap](nyx-bootstrap.md) — this playbook applied to the four cluster machines.
