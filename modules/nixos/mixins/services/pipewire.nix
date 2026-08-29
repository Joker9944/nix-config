{ mkMixinModule, ... }:
{ lib, ... }:
mkMixinModule "pipewire" {
  security.rtkit.enable = lib.mkDefault true;
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
