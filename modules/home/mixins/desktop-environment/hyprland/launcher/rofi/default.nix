{ mkHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-unstable,
  ...
}:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
in
mkHyprlandModule {
  options.mixins.desktopEnvironment.hyprland.launcher.rofi =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "rofi hyprland launcher";
    };

  config = lib.mkIf cfg.launcher.rofi.enable {
    programs.rofi = {
      enable = true;
      package = pkgs-unstable.rofi;

      extraConfig = {
        display-drun = "launch";
        display-window = "switch";
        scroll-method = 1;

        # Only `drun` honours these; rofi bypasses both once it launches via GIO,
        # which silently returns apps to the compositor's unit. Recheck on bump.
        run-command = cfg.lib.mkAppCommand { elems = [ "{cmd}" ]; };
        run-shell-command = cfg.lib.mkAppCommand {
          elems = [
            "{terminal}"
            "-e"
            "{cmd}"
          ];
        };
      };

      modes = [
        "drun"
        "window"
      ];

      plugins = [ pkgs-unstable.rofi-calc ];

      terminal = cfg.terminal.package.meta.mainProgram;

      # cSpell:words rasi
      theme = import ./theme.rasi.nix {
        inherit config cfg;
        inherit (config.lib.formats) rasi;
      };
    };

    mixins.desktopEnvironment.hyprland.launcher.toggleCommand = "pkill --exact \\\"rofi\\\" || ${
      cfg.lib.mkAppCommand {
        elems = [
          "rofi"
          "-show"
          "drun"
          "-show-icons"
        ];
      }
    }";
  };
}
