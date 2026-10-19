{ mkMixinModule, ... }:
{ lib, osConfig, ... }:
mkMixinModule "ollama" {
  services.ollama = {
    enable = true;
    acceleration = lib.mkIf osConfig.mixins.hardware.nvidiaCuda.enable "cuda";
  };
}
