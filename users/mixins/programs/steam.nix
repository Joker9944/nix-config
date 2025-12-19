{
  lib,
  config,
  osConfig,
  ...
}:
{
  options.mixins.programs.steam =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "steam config mixin" // {
        default = osConfig.mixins.programs.steam.enable;
      };
    };

  config =
    let
      cfg = config.mixins.programs.steam;
    in
    lib.mkIf cfg.enable {
      programs.gamemode = {
        enable = true;
        package = null;
      };
    };
}
