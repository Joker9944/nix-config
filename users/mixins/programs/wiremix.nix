{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.programs.wiremix =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "wiremix config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.wiremix;
    in
    lib.mkIf cfg.enable {
      home.packages = [ pkgs.wiremix ];
    };
}
