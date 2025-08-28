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
      portalPackage = pkgs-hyprland.xdg-desktop-portal-hyprland;

      withUWSM = true;
    };

    # WORKAROUND This is a hack to workaround a hack in NixOS
    # See here: https://github.com/NixOS/nixpkgs/pull/297434#issuecomment-2348783988
    # Remove when https://github.com/NixOS/nixpkgs/blob/fafef5049e2a7bcc36802e1ce72cd2f51d386388/nixos/modules/services/x11/display-managers/default.nix#L28-L50 ever gets fixed
    systemd.services.display-manager.environment.XDG_CURRENT_DESKTOP = "X-NIXOS-SYSTEMD-AWARE";

    environment.systemPackages = with pkgs-hyprland; [ kitty ];

    # Override graphics drivers with the ones from Hyprland
    hardware.graphics = {
      package = pkgs-hyprland.mesa;
      package32 = pkgs-hyprland.pkgsi686Linux.mesa;
    };

    services = {
      # Since I do like the GNOME ecosystem enable this for GNOME keyring, online accounts, etc.
      gnome.core-os-services.enable = true;
      # Needed for mounting disks without root privileges
      udisks2.enable = true;
    };
  };
}
