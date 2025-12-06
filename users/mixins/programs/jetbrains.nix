{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.programs.jetbrains =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "jetbrains config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.jetbrains;
    in
    lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        jetbrains.idea-ultimate
        jetbrains.pycharm-professional
        jetbrains.webstorm
        jetbrains.goland
        nodejs
      ];

      programs.openjdk.versions = [
        8
        11
        17
        21
      ];
    };
}
