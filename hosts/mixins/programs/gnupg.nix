{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.programs.gnupg =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "gnupg config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.gnupg;
    in
    lib.mkIf cfg.enable {
      programs.gnupg = {
        package = pkgs.gnupg1;
        agent.enable = lib.mkDefault true;
      };
    };
}
