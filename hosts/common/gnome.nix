{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.common.desktopEnvironment.gnome;
in {
  options.common.desktopEnvironment.gnome = with lib; {
    enable = mkEnableOption "Whether to enable GNOME desktop environment.";
  };

  config = lib.mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;

        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };

      # Must be on for the Firefox GNOME shell integration extension
      gnome.gnome-browser-connector.enable = config.programs.firefox.enable;
    };

    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-connections
      epiphany # web browser
    ];

    programs = {
      gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

      # Force install the GNOME shell integration extension
      firefox.policies.ExtensionSettings."chrome-gnome-shell@gnome.org" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/gnome-shell-integration/latest.xpi";
        installation_mode = "force_installed";
      };
    };
  };
}
