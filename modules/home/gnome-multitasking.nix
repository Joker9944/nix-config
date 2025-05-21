{
  lib,
  config,
  ...
}: let
  cfg = config.programs.gnome-multitasking;
in {
  options.programs.gnome-multitasking = with lib; {
    enable = mkEnableOption "Whether to enable GNOME multitasking config.";
    hotCorner = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable the top-left hot corner.
      '';
    };
    activeScreenEdges = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable active screen edges.
      '';
    };
    workspaces = mkOption {
      type = types.enum [
        "dynamic"
        "fixed"
      ];
      default = "dynamic";
      description = ''
        Whether the number of workspaces should automaticly expand or be fixed.
      '';
    };
    numberOfWorkspaces = mkOption {
      type = types.int;
      default = 4;
      description = ''
        The amount of by default open workspaces, only works with fixed workspaces.
      '';
    };
    multiMonitor = mkOption {
      type = types.enum [
        "primary-only"
        "all-displays"
      ];
      default = "primary-only";
      description = ''
        Should workspaces only be on the primary display or all displays.
      '';
    };
    appSwitching = mkOption {
      type = types.enum [
        "all-workspaces"
        "current-workspace"
      ];
      default = "all-workspaces";
      description = ''
        Should the app switcher include apps from all workspaces or the current workspace only
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    dconf.settings = with lib.hm.gvariant; {
      "org/gnome/desktop/interface" = {
        enable-hot-corners = cfg.hotCorner;
      };
      "org/gnome/mutter" = {
        edge-tiling = cfg.activeScreenEdges;
        dynamic-workspaces = cfg.workspaces == "dynamic";
        workspaces-only-on-primary = cfg.multiMonitor == "primary-only";
      };
      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = lib.mkIf (cfg.workspaces == "fixed") cfg.numberOfWorkspaces;
      };
      "org/gnome/shell/app-switcher" = {
        current-workspace-only = cfg.appSwitching == "current-workspace";
      };
    };
  };
}
