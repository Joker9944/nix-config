{ lib, pkgs, ... }:
{
  options.windowManager.hyprland.custom.terminal =
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
            id,
            command,
            ...
          }:
          "kitty --override confirm_os_window_close=0 --app-id ${id} ${command}";
        description = ''
          Function to generate a command to run a command in terminal.
        '';
      };

      mkWindowRules = mkOption {
        type = types.functionTo (types.listOf types.str);
        default =
          {
            id,
            ...
          }:
          [ "minsize 720 480, class:${id}" ];
        description = ''
          Function to generate Hyprland window rules for terminal windows.
        '';
      };
    };
}
