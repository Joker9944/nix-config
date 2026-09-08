{ mkMixinModule, ... }:
{ lib, ... }:
mkMixinModule "nvidiaCuda" {
  # CUDA EULA comes from the nvidia mixin, which this is always paired with.
  custom.nixpkgsCompat.allowUnfreeLicenses = [ "cuDNN EULA" ];

  # Rebuilds a large part of the package set against CUDA, so it is opt-in
  # separately from the driver: a host that only needs NVENC/NVDEC does not
  # want it.
  nixpkgs.config.cudaSupport = true;

  nix.settings = {
    substituters = lib.toList "https://cache.nixos-cuda.org";
    trusted-public-keys = lib.toList "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="; # cSpell:disable-line
  };
}
