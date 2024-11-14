{ config, pkgs, ... }:

{
  services.xserver = {
    enabled = true;

    displayManager = {
      gmd.enable = true;
      gnome.enable = true;
    };
  };

  environment.systemPackages = with pkgs.gnomeExtensions; [
    tophat
    clipboard-history
    auto-move-windows
  ];
}
