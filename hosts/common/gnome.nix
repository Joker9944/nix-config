{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.desktopEnvironment.gnome;
in
{
  options.desktopEnvironment.gnome = with lib; {
    enable = mkEnableOption "Whether to enable GNOME desktop environment.";
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;

      desktopManager.gnome.enable = true;
    };

    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-connections
      epiphany # web browser
    ];
  };
}
