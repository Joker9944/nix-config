{ mkMixinModule, ... }:
{ lib, ... }:
mkMixinModule "vim" {
  programs = {
    # Disable nano and switch to vim as default
    nano.enable = lib.mkDefault false;
    vim = {
      enable = lib.mkDefault true;
      defaultEditor = lib.mkDefault true;
    };
  };
}
