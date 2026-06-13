{ mkDefaultHyprlandModule, ... }:
{
  lib,
  pkgs,
  config,
  osConfig,
  custom,
  ...
}:
let
  cfg = config.wayland.windowManager.hyprland;
  inherit (custom.lib) mkCommand;
in
mkDefaultHyprlandModule { dir = ./.; } {
  options.mixins.desktopEnvironment.hyprland.system =
    let
      inherit (lib) mkOption types;
    in
    {
      mkRunCommand = mkOption {
        type = types.functionTo types.str;
        default =
          {
            command,
            args ? [ ],
            ...
          }:
          mkCommand [
            command
            args
          ];
        description = ''
          Function to generate a command to run a arbitrary command.
        '';
      };

      mkRunDesktopEntry = mkOption {
        type = types.functionTo types.str;
        default =
          {
            entry,
            ...
          }:
          mkCommand [
            (lib.getExe' pkgs.gtk3 "gtk-launcher")
            entry
          ];
        description = ''
          Function to generate a command to run a desktop entry app.
        '';
      };

      mkLuaRunPart = mkOption {
        type = types.functionTo types.str;
        default = args: lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${cfg.system.mkRunCommand args}\")";
      };
    };

  config = {
    # WORKAROUND This is a hack to workaround a hack in NixOS
    # See here: https://github.com/NixOS/nixpkgs/pull/297434#issuecomment-2348783988
    # Remove when https://github.com/NixOS/nixpkgs/blob/fafef5049e2a7bcc36802e1ce72cd2f51d386388/nixos/modules/services/x11/display-managers/default.nix#L28-L50 ever gets fixed
    home.sessionVariables.XDG_CURRENT_DESKTOP = "Hyprland";

    mixins.desktopEnvironment.hyprland.system = {
      mkRunCommand =
        {
          command,
          uwsmArgs ? [ ],
          args ? [ ],
          ...
        }:
        mkCommand [
          "uwsm"
          "app"
          uwsmArgs
          "--"
          command
          args
        ];

      mkRunDesktopEntry =
        {
          entry,
          uwsmArgs ? [ ],
          args ? [ ],
          ...
        }:
        mkCommand [
          "uwsm"
          "app"
          uwsmArgs
          "--"
          entry
          args
        ];
    };

    wayland = {
      systemd.target = lib.mkIf cfg.systemd.enable "hyprland-session.target";

      windowManager.hyprland = {
        inherit (osConfig.programs.hyprland) package portalPackage;
        enable = true;

        systemd.enable = !osConfig.programs.hyprland.withUWSM;

        configType = "lua";
      };
    };
  };
}
