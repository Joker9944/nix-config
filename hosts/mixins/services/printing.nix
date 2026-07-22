{ mkMixinModule, ... }:
{ lib, pkgs, ... }:
mkMixinModule "printing" {
  services = {
    # Enable cups by default
    printing = {
      enable = lib.mkDefault true;
      drivers = [ pkgs.epson-escpr ];
    };
  };
}
