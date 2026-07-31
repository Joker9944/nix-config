# Hosts

Six x86_64-linux machines, all owned by user `joker9944` — two graphical, four headless. See [architecture/entry-points](/architecture/entry-points.md) for how the host records in `flake.nix` get turned into `nixosConfigurations` and `homeConfigurations`.

# Machines

* [HAL9000](HAL9000.md) — desktop with three monitors and an Nvidia GPU.
* [wintermute](wintermute.md) — Lenovo ThinkPad X1 Yoga Gen 4 laptop, Swiss keymap.
* [nyx-cluster](nyx-cluster.md) — `tars`, `case`, `kipp`, `mother`: the headless k3s cluster.
