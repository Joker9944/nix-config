{
  lib,
  config,
  ...
}:
{
  options.mixins.programs.zoom =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "zoom config mixin";
    };

  config.programs.zoom =
    let
      cfg = config.mixins.programs.zoom;
    in
    {
      inherit (cfg) enable;
    };
}
