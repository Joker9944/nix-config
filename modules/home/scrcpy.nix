{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.programs.scrcpy =
    let
      inherit (lib)
        mkEnableOption
        mkPackageOption
        mkOption
        types
        ;
    in
    {
      enable = mkEnableOption "scrcpy";

      package = mkPackageOption pkgs "scrcpy" { };

      args = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Arguments passed to scrcpy on startup.
        '';
      };
    };

  config =
    let
      cfg = config.programs.scrcpy;
      argsWrapper = pkgs.runCommand "scrcpy" { nativeBuildInputs = [ pkgs.makeBinaryWrapper ]; } ''
        mkdir -p $out/bin
        makeWrapper ${lib.getExe cfg.package} $out/bin/scrcpy --inherit-argv0 --add-flags "${toString cfg.args}"
      '';
    in
    lib.mkIf cfg.enable {
      home.packages = if cfg.args == [ ] then [ cfg.package ] else [ argsWrapper ];
    };
}
