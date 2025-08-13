{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.desktopEnvironment.kde-plasma;
in {
  options.desktopEnvironment.kde-plasma = with lib; {
    enable = mkEnableOption "Whether to enable KDE Plasma desktop environment.";
  };

  config = lib.mkIf cfg.enable {
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      kate
    ];

    services.xserver = {
      enable = true;

      displayManager.sddm.enable = true;
      desktopManager.plasma6.enable = true;
    };
  };
}
