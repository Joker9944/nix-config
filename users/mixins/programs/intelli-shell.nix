{
  lib,
  config,
  ...
}:
{
  options.mixins.programs.intelli-shell =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "intelli-shell base mixin";
    };

  config.programs.intelli-shell =
    let
      cfg = config.mixins.programs.intelli-shell;
    in
    {
      inherit (cfg) enable;

      settings = {
        check_updates = false;
      };
    };
}
