/*
  References:
   - https://wiki.hypr.land/Nix/
   - https://wiki.hypr.land/Nix/Hyprland-on-NixOS/
   - https://wiki.hypr.land/Nix/Hyprland-on-Home-Manager/
   - https://wiki.hypr.land/Nvidia/
*/
{
  lib,
  config,
  pkgs-hyprland,
  ...
}:
let
  cfg = config.desktopEnvironment.hyprland;
in
{
  options.desktopEnvironment.hyprland = with lib; {
    enable = mkEnableOption "Hyprland desktop environment";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      package = pkgs-hyprland.hyprland;
    };

    environment.systemPackages = with pkgs-hyprland; [ kitty ];

    # Override graphics drivers with the ones from Hyprland
    hardware.graphics = {
      package = pkgs-hyprland.mesa;
      package32 = pkgs-hyprland.pkgsi686Linux.mesa;
    };

    # Needed for mounting disks without root privileges
    services.udisks2.enable = true;
  };
}
