{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.mixins.desktopEnvironment.gnome =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "GNOME desktop environment config mixin";
    };

  config =
    let
      cfg = config.mixins.desktopEnvironment.gnome;
    in
    lib.mkIf cfg.enable {
      services = {
        xserver = {
          enable = true;

          desktopManager.gnome.enable = true;
        };

        gnome.gnome-browser-connector.enable = true;
      };

      programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

      environment.gnome.excludePackages = with pkgs; [
        gnome-tour
        gnome-connections
        epiphany # web browser
      ];
    };
}
