# Architecture

The concepts here explain the shape of the repo — the ones a newcomer (human or agent) has to piece together from several files to see. Prefer reading these before proposing structural changes.

# Structural patterns

* [mixin-pattern](mixin-pattern.md) — Every reusable module is a binary-enable mixin under `options.mixins.<category>.<name>`. Hosts and users opt in from central `mixins.nix` files.
* [profiles](profiles.md) — The role layer above mixins: a `hosts/profiles/*.nix` module bundles a class of machine's mixin enables, selected per host by the `profile` string in the flake record. High-level and shared — never per-machine.
* [module-layout](module-layout.md) — Folder/`files/` conventions for how any nix module (mixin or otherwise) is arranged on disk once it grows beyond a single `.nix` file.
* [comment-markers](comment-markers.md) — `TODO` / `WORKAROUND` / `HACK` / `UPGRADE` and what each promises about how long the code stays, plus the optional id that groups a marker across files.
* [auto-discovery](auto-discovery.md) — `custom.lib.modules.mkDefaultModule` auto-imports every sibling `.nix` file in a directory, so dropping a file into `users/mixins/programs/` is enough to register it.
* [entry-points](entry-points.md) — `mkNixosConfiguration` and `mkHomeConfiguration` are the two constructors called from `flake.nix`. Understanding them explains how NixOS and home-manager configurations stay paired.
* [custom-lib](custom-lib.md) — Two directory-loaded libs: `lib/` for module-system helpers (`custom.lib`), the `apps/util-lib` flake for general-purpose ones (`libUtil`).
* [packages](packages.md) — Flake packages live under `./pkgs`, auto-discovered by `pkgs/default.nix` (top-level `.nix` = a package, subdirs = shared support); `flake.nix` stays lean.
* [hyprland-lua-config](hyprland-lua-config.md) — The hyprland tree emits `hyprland.lua`, not `hyprland.conf`: where `settings` nests, and why `nix build` proves nothing about a rule's validity — key vocabulary is upstream's, checked at runtime.
* [uwsm-session](uwsm-session.md) — Hyprland runs as a systemd unit under UWSM, so binds and rofi must launch long-running apps through `cfg.mkAppCommand` or they end up inside the compositor's own unit.
