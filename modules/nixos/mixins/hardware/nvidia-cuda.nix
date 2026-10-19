{ mkMixinModule, ... }:
{ lib, ... }:
mkMixinModule "nvidiaCuda" {
  # A capability flag, not a package-set switch: consumers read
  # `mixins.hardware.nvidiaCuda.enable` and opt in per package. Setting
  # `nixpkgs.config.cudaSupport` instead rebuilds every downstream consumer of a
  # CUDA-aware library, and the cache below carries only the libraries.

  # CUDA EULA comes from the nvidia mixin, which this is always paired with.
  custom.nixpkgsCompat.allowUnfreeLicenses = [ "cuDNN EULA" ];

  nix.settings = {
    substituters = lib.toList "https://cache.nixos-cuda.org";
    trusted-public-keys = lib.toList "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="; # cSpell:disable-line
  };
}
