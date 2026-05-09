{ lib, config, ... }:
{
  options.mixins.programs.systemctl-tui =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "systemctl-tui config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.systemctl-tui;
    in
    lib.mkIf cfg.enable {
      home.shellAliases.st = "systemctl-tui";

      programs.systemctl-tui.enable = true;
    };
}
