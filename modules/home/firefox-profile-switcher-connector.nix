{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.firefox-profile-switcher-connector;
in
{
  options.services.firefox-profile-switcher-connector =
    let
      inherit (lib) mkEnableOption mkPackageOption;
    in
    {
      enable = mkEnableOption "Firefox profile switcher";
      package = mkPackageOption pkgs "firefox-profile-switcher-connector" { };
    };

  config = {
    home.packages = [ cfg.package ];

    xdg.configFile."firefoxprofileswitcher/config.json".text = builtins.toJSON {
      browser_binary = lib.getExe config.programs.firefox.package;
    };

    programs.firefox.nativeMessagingHosts = [ cfg.package ];
  };
}
