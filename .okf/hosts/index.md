# Hosts

Seven x86_64-linux machines, all owned by user `joker9944` — two graphical, five headless. See [architecture/entry-points](/architecture/entry-points.md) for how the host records in `flake.nix` get turned into `nixosConfigurations` and `homeConfigurations`.

# Machines

* [HAL9000](HAL9000.md) — desktop with three monitors and an Nvidia GPU.
* [wintermute](wintermute.md) — Lenovo ThinkPad X1 Yoga Gen 4 laptop, Swiss keymap.
* [nyx-cluster](nyx-cluster.md) — `tars`, `case`, `kipp`, `mother`: the headless k3s cluster.
* [wopr](wopr.md) — the public ingress edge VPS; not a cluster member.

Each host's `greeting.nix` sets its `custom.greeting` art and taglines (one picked at random) — the interactive-shell banner, hooked into `/etc/bashrc` only. Fish needs no hook: on the desktops bash `exec`s into it after printing, and `GREETING_SHOWN` keeps nested shells quiet. Rendered by fastfetch from a generated config; the `server` profile adds load, memory and disk modules, and each host hardcodes `diskCount` (the mounts fastfetch shows) so the block stays centred. ZFS datasets are hidden from `disk` — they report the dataset, not the pool — so mother adds a `zpool` line, which pulls in a libzfs-enabled fastfetch.
