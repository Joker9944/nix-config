{
  lib,
  pkgs,
  config,
  ...
}:
let
  iniFormat = pkgs.formats.ini { };
in
{
  options.programs.gamemode =
    let
      inherit (lib)
        mkEnableOption
        mkPackageOption
        mkOption
        literalExpression
        ;
    in
    {
      enable = mkEnableOption "feral gamemode";

      package = mkPackageOption pkgs "gamemode" {
        nullable = true;
      };

      config = mkOption {
        inherit (iniFormat) type;
        default = { };
        example = literalExpression ''
          {
            general = {
              reaper_freq = 5;
              inhibit_screensaver = 1;
            };

            custom = {
              start = [ "notify-send \"GameMode started\"" ];
              end = [ "notify-send \"GameMode ended\"" ];
            };
          }
        '';
        description = ''
          Configuration for gamemode. Example can be found here:
          <https://github.com/FeralInteractive/gamemode/blob/master/example/gamemode.ini>
        '';
      };
    };

  config =
    let
      cfg = config.programs.gamemode;
    in
    lib.mkIf cfg.enable {
      home.packages = lib.optional (cfg.package != null) cfg.package;

      xdg.configFile."gamemode.ini" = lib.mkIf (cfg.config != { }) {
        source = iniFormat.generate "gamemode.ini" cfg.config;
      };
    };
}
