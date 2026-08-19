{ mkDefaultHyprlandModule, ... }:
{
  lib,
  config,
  osConfig,
  custom,
  ...
}:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
  waylandCfg = config.wayland.windowManager.hyprland;
in
mkDefaultHyprlandModule { dir = ./.; } {
  options.mixins.desktopEnvironment.hyprland =
    let
      inherit (lib) mkOption types;
    in
    {
      mkAppCommand = mkOption {
        type = types.functionTo types.str;
        default =
          {
            elems ? [ ],
            ...
          }:
          custom.libUtil.strings.mkCommand elems;
        description = ''
          Wrap a command so UWSM launches it as its own unit in `app-graphical.slice`
          instead of inside the compositor's unit. `name` overrides the unit name UWSM
          derives from the command, which matters when several apps share an argv[0].
        '';
      };

      mkAppEntryCommand = mkOption {
        type = types.functionTo types.str;
        default = { package, ... }: lib.getExe package;
        description = ''
          Launch an app by its desktop entry ID so UWSM can read the entry's metadata.
          Falls back to the package's main program when UWSM is not managing the session,
          where an entry ID would not be executable.
        '';
      };
    };

  config = {
    # WORKAROUND(stoic-ritchie) This is a hack to workaround a hack in NixOS
    # See here: https://github.com/NixOS/nixpkgs/issues/297434#issuecomment-2348783988 (merged; not the removal condition) krank:ignore-line
    # Remove when https://github.com/NixOS/nixpkgs/blob/fafef5049e2a7bcc36802e1ce72cd2f51d386388/nixos/modules/services/x11/display-managers/default.nix#L28-L50 ever gets fixed
    home.sessionVariables.XDG_CURRENT_DESKTOP = "Hyprland";

    mixins.desktopEnvironment.hyprland = lib.mkIf osConfig.programs.hyprland.withUWSM {
      mkAppCommand =
        {
          elems ? [ ],
          name ? null,
          ...
        }:
        custom.libUtil.strings.mkCommand [
          "uwsm-app"
          (lib.optional (name != null) [
            "-a"
            name
          ])
          "--"
          elems
        ];

      mkAppEntryCommand = args: cfg.mkAppCommand { elems = [ (custom.lib.requireDesktopFile args) ]; };
    };

    wayland = {
      systemd.target = lib.mkIf waylandCfg.systemd.enable "hyprland-session.target";

      windowManager.hyprland = {
        inherit (osConfig.programs.hyprland) package portalPackage;
        enable = true;

        systemd.enable = !osConfig.programs.hyprland.withUWSM;

        configType = "lua";
      };
    };
  };
}
