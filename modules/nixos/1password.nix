{
  config,
  lib,
  ...
}:
let
  cfg = config.programs._1password-gui;
in
{
  options.programs._1password-gui = with lib; {
    additionalAllowedBrowsers = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Which browsers should be able to integrate with 1password which are not automatically detected.
      '';
    };
  };

  config = lib.mkIf config.programs._1password-gui.enable {
    environment.etc."1password/custom_allowed_browsers".text =
      let
        browsers = cfg.additionalAllowedBrowsers ++ lib.optional config.programs.firefox.enable "firefox";
      in
      lib.mkIf (browsers != [ ]) (lib.concatLines browsers);
  };
}
