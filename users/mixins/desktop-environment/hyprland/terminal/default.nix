{ mkDefaultHyprlandModule, ... }:
{ lib, ... }:
mkDefaultHyprlandModule { dir = ./.; } {
  options.mixins.desktopEnvironment.hyprland.terminal =
    let
      inherit (lib) mkOption types;
    in
    {
      mkRunCommand = mkOption {
        type = types.functionTo types.str;
        description = ''
          Function to generate a command to run a command in terminal.
        '';
      };

      mkWindowRules = mkOption {
        type = types.functionTo (types.listOf types.attrs);
        description = ''
          Function to generate Hyprland window rules for terminal windows.
        '';
      };
    };
}
