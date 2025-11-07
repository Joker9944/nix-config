{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.mixins.desktopEnvironment.kde-plasma =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "KDE Plasma desktop environment config mixin";
    };

  config =
    let
      cfg = config.mixins.desktopEnvironment.kde-plasma;
    in
    lib.mkIf cfg.enable {
      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        kate
      ];

      services.xserver = {
        enable = true;

        desktopManager.plasma6.enable = true;
      };
    };
}
