{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.programs.jupyter =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "jupyter config mixin";
    };

  config.home.packages =
    let
      cfg = config.mixins.programs.jupyter;
    in
    lib.mkIf cfg.enable [
      (pkgs.python3.withPackages (
        # cSpell:words numpy sympy seaborn
        ps: with ps; [
          jupyter
          numpy
          pandas
          sympy
          seaborn
        ]
      ))
    ];
}
