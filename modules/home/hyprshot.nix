{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.hyprshot;
in
{
  options.programs.hyprshot = with lib; {
    enable = mkEnableOption "the hyprshot screenshot utility";
    package = mkPackageOption pkgs "hyprshot" { };
    saveLocation = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "$HOME/Pictures/Screenshots";
      description = ''
        Set the `$HYPRSHOT_DIR` environment variable to the given location.

        Hyprshot will save new screen shots to the first expression that resolves:
         - `$HYPRSHOT_DIR`
         - `$XDG_PICTURES_DIR`
         - `$(xdg-user-dir PICTURES)`
      '';
    };
  };

  config.home = lib.mkIf cfg.enable {
    packages = [ cfg.package ];

    sessionVariables.HYPRSHOT_DIR = cfg.saveLocation;
  };
}
