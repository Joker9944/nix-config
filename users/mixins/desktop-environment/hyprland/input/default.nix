{ mkDefaultHyprlandModule, ... }:
{ lib, ... }:
mkDefaultHyprlandModule { dir = ./.; } {
  options.mixins.desktopEnvironment.hyprland.binds =
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

  config = {
    mixins.desktopEnvironment.hyprland.binds.mods = {
      main = "SUPER";
      workspace = "SUPER + SHIFT";
      utility = "SUPER + CTRL";
      app = "SUPER + ALT";
    };
  };
}
