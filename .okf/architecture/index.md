# Architecture

The concepts here explain the shape of the repo — the ones a newcomer (human or agent) has to piece together from several files to see. Prefer reading these before proposing structural changes.

# Structural patterns

* [mixin-pattern](mixin-pattern.md) — Every reusable module is a binary-enable mixin under `options.mixins.<category>.<name>`. Hosts and users opt in from central `mixins.nix` files.
* [auto-discovery](auto-discovery.md) — `custom.lib.mkDefaultModule` auto-imports every sibling `.nix` file in a directory, so dropping a file into `users/mixins/programs/` is enough to register it.
* [entry-points](entry-points.md) — `mkNixosConfiguration` and `mkHomeConfiguration` are the two constructors called from `flake.nix`. Understanding them explains how NixOS and home-manager configurations stay paired.
* [custom-lib](custom-lib.md) — Files in `lib/` are auto-discovered, exposed under `self.lib`, and passed into every module as `custom.lib`.
