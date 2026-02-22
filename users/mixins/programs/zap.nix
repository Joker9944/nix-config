{
  lib,
  config,
  ...
}:
{
  options.mixins.programs.zap =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "zap config mixin";
    };

  config.programs.zap =
    let
      cfg = config.mixins.programs.zap;
    in
    {
      inherit (cfg) enable;
    };
}
