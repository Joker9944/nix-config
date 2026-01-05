{
  config,
  lib,
  ...
}:
{
  options.programs._1password-gui =
    let
      inherit (lib) mkOption types;
    in
    {
      additionalAllowedBrowsers = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Which browsers should be able to integrate with 1password which are not automatically detected.
        '';
      };
    };

  config =
    let
      cfg = config.programs._1password-gui;
    in
    lib.mkIf cfg.enable {
      environment.etc."1password/custom_allowed_browsers" =
        let
          browsers = cfg.additionalAllowedBrowsers ++ lib.optional config.programs.firefox.enable "firefox";
        in
        lib.mkIf (browsers != [ ]) {
          text = lib.concatLines browsers;
        };
    };
}
