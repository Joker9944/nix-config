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
          variant = "SUPER + SHIFT";
          app = "SUPER + CTRL";
        };
        description = ''
          Modifier tier per bind category. Tier semantics live in
          `.okf/architecture/shortcut-scheme.md`.
        '';
      };
    };
}
