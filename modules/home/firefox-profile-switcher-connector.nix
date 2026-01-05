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
      inherit (lib)
        mkEnableOption
        mkPackageOption
        mkOption
        types
        ;
    in
    {
      enable = mkEnableOption "Firefox profile switcher";

      package = mkPackageOption pkgs "firefox-profile-switcher-connector" { };

      browser = mkOption {
        type = types.enum [
          "firefox"
          "librewolf"
        ];
        default = "firefox";
        description = ''
          The firefox-profile-switcher only works with one browser at a time.
        '';
      };
    };

  config = {
    xdg.configFile."firefoxprofileswitcher/config.json".text = builtins.toJSON (
      {
        browser_binary = lib.getExe config.programs.${cfg.browser}.finalPackage;
      }
      // lib.optionalAttrs (cfg.browser == "librewolf") {
        browser_profile_dir = "${config.home.homeDirectory}/.librewolf";
      }
    );

    programs.${cfg.browser}.nativeMessagingHosts = [ cfg.package ];
  };
}
