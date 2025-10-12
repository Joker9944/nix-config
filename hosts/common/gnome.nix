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
    services = {
      xserver = {
        enable = true;

        desktopManager.gnome.enable = true;
      };

      gnome.gnome-browser-connector.enable = config.programs.firefox.enable;
    };

    programs = {
      gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

      firefox.policies.ExtensionSettings."chrome-gnome-shell@gnome.org" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/gnome-shell-integration/latest.xpi";
        installation_mode = "force_installed";
      };
    };

    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-connections
      epiphany # web browser
    ];
  };
}
