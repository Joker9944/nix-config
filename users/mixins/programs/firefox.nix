{
  lib,
  config,
  osConfig,
  ...
}:
{
  options.mixins.programs.firefox =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "firefox config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.firefox;
      inherit (osConfig.programs.firefox) package;
    in
    lib.mkIf cfg.enable {
      programs.firefox = {
        enable = true;
        inherit package;
      };

      services.firefox-profile-switcher-connector.enable = true;

      xdg.mimeApps.custom.apps.default = [ "${package}/share/applications/firefox.desktop" ];
    };
}
