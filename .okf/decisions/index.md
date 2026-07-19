# Decisions

Load-bearing choices behind the shape of the repo. Consult before proposing structural changes — these encode the *why*, so future work stays coherent with the past.

# Decisions

* [standalone-home-manager](standalone-home-manager.md) — Home-manager runs as a separate flake output, not as a NixOS module.
* [enable-flag-mixins](enable-flag-mixins.md) — Every mixin exposes exactly one option (`enable`); knobs live in per-host overrides.
* [release-policy](release-policy.md) — Track stable nixos in lockstep with matching home-manager; hyprland is the exception.
