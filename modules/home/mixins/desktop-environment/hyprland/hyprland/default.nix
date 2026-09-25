{
  mkDefaultHyprlandModule,
  flake,
  libUtil,
  ...
}:
{
  lib,
  pkgs,
  config,
  osConfig,
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
          libUtil.strings.mkCommand elems;
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

      mkAppWorkspace = mkOption {
        type = types.functionTo types.attrs;
        default =
          {
            id,
            # the scheme keys app-tier letters to the app's initial; deviations override
            key ? lib.toUpper (lib.substring 0 1 id),
            class,
            launch,
            # only for autostarted apps, so login assignment doesn't summon the workspace
            silent ? false,
          }:
          {
            bind = [
              (flake.lib.hyprland.mkLuaCall [
                "${cfg.binds.mods.app} + ${key}"
                (lib.generators.mkLuaInline "hl.dsp.workspace.toggle_special(\"${id}\")")
                { description = "toggle ${id} special workspace"; }
              ])
            ];
            workspace_rule = [
              {
                workspace = "special:${id}";
                layout = "scrolling";
                on_created_empty = launch;
              }
            ];
            window_rule = [
              {
                name = id;
                match.class = class;
                workspace = "special:${id}${lib.optionalString silent " silent"}";
              }
            ];
          };
        description = ''
          Compose the app-tier summon pattern for one app: the toggle bind, the special
          workspace's scrolling rule with its launch fallback, and the window assignment.
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
        libUtil.strings.mkCommand [
          "uwsm-app"
          (lib.optional (name != null) [
            "-a"
            name
          ])
          "--"
          elems
        ];

      mkAppEntryCommand =
        args: cfg.mkAppCommand { elems = [ (flake.lib.requireDesktopFile ({ inherit pkgs; } // args)) ]; };
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
