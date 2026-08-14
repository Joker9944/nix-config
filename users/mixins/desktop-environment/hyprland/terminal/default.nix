{ mkDefaultHyprlandModule, ... }:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
in
mkDefaultHyprlandModule { dir = ./.; } {
  options.mixins.desktopEnvironment.hyprland.terminal =
    let
      inherit (lib) mkPackageOption mkOption types;
    in
    {
      package = mkPackageOption pkgs "terminal" {
        default = null;
      };

      mkRunCommand = mkOption {
        type = types.functionTo types.str;
        default =
          {
            command,
            ...
          }:
          cfg.mkAppCommand {
            elems = [
              "kitty"
              command
            ];
          };
        description = ''
          Function to generate a command to run a command in terminal.
        '';
      };

      mkWindowRules = mkOption {
        type = types.functionTo (types.listOf types.attrs);
        default =
          { id, ... }:
          [ "minsize 720 480, class:${id}" ];
        description = ''
          Function to generate Hyprland window rules for terminal windows.
        '';
      };
    };
}
