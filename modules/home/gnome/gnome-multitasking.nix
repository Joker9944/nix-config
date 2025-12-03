{
  lib,
  config,
  custom,
  ...
}:
let
  cfg = config.gnome-settings.multitasking;
in
{
  options.gnome-settings.multitasking = with lib; {
    enable = mkEnableOption "GNOME multitasking config";

    hotCorner = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Whether to enable the top-left hot corner.
      '';
    };

    activeScreenEdges = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Whether to enable active screen edges.
      '';
    };

    workspaces = mkOption {
      type = types.nullOr (
        types.enum [
          "dynamic"
          "fixed"
        ]
      );
      default = null;
      description = ''
        Whether the number of workspaces should automatically expand or be fixed.
      '';
    };

    numberOfWorkspaces = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = ''
        The amount of by default open workspaces, only works with fixed workspaces.
      '';
    };

    multiMonitor = mkOption {
      type = types.nullOr types.enum [
        "primary-only"
        "all-displays"
      ];
      default = null;
      description = ''
        Should workspaces only be on the primary display or all displays.
      '';
    };

    appSwitching = mkOption {
      type = types.nullOr (
        types.enum [
          "all-workspaces"
          "current-workspace"
        ]
      );
      default = null;
      description = ''
        Should the app switcher include apps from all workspaces or the current workspace only
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        enable-hot-corners = custom.lib.nonNull cfg.hotCorner;
      };

      "org/gnome/mutter" = {
        edge-tiling = custom.lib.nonNull cfg.activeScreenEdges;
        dynamic-workspaces = lib.mkIf (cfg.workspaces != null) (cfg.workspaces == "dynamic");
        workspaces-only-on-primary = lib.mkIf (cfg.multiMonitor != null) cfg.multiMonitor == "primary-only";
      };

      # TODO this ´lib.mkIf´ is a hack to get this to work, find a way to directly pass null.
      "org/gnome/desktop/wm/preferences" = lib.mkIf (cfg.numberOfWorkspaces != null) {
        num-workspaces = cfg.numberOfWorkspaces;
      };

      "org/gnome/shell/app-switcher" = {
        current-workspace-only = lib.mkIf (cfg.appSwitching != null) (
          cfg.appSwitching == "current-workspace"
        );
      };
    };
  };
}
