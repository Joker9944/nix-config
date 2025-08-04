{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.programs._1password-gui;
in {
  options.programs._1password-gui = with lib; {
    additionalAllowedBrowsers = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Which browsers should be able to integrate with 1password which are not automatically detected.
      '';
    };
  };

  config = lib.mkIf config.programs._1password-gui.enable {
    environment.etc."1password/custom_allowed_browsers".text = let
      firefoxCfg = config.programs.firefox;

      browsers =
        cfg.additionalAllowedBrowsers
        ++ lib.optional (firefoxCfg.enable && firefoxCfg.package == pkgs.firefox) "firefox"
        ++ lib.optional (firefoxCfg.enable && firefoxCfg.package == pkgs.librewolf) "librewolf";
    in
      lib.mkIf (browsers != []) (lib.concatLines browsers);
  };
}
