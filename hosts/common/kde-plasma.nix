{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.common.desktopEnvironment.kde-plasma;
in {
  options.common.desktopEnvironment.kde-plasma = with lib; {
    enable = mkEnableOption "Whether to enable KDE Plasma desktop environment.";
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kate
  ];

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;

      displayManager.sddm.enable = true;
      desktopManager.plasma6.enable = true;
    };
  };
}
