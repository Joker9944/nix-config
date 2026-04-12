{ lib, ... }:
{
  options.windowManager.hyprland.custom.binds =
    let
      inherit (lib) mkOption types;
    in
    {
      mods = mkOption {
        type = types.attrsOf types.str;
        default = {
          main = "SUPER";
        };
        example = ''
          {
            main = "SUPER";
            workspace = "SUPER SHIFT";
            utility = "SUPER CTRL";
          }
        '';
        description = ''
          Option to reuse mods without using Hyprland vars.
        '';
      };
    };
}
