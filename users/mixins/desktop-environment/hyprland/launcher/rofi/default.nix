{ mkHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-unstable,
  custom,
  ...
}:
mkHyprlandModule {
  config =
    let
      cfg = config.mixins.desktopEnvironment.hyprland;
    in
    lib.mkIf (cfg.launcher.type == "rofi") {
      programs.rofi = {
        enable = true;
        package = pkgs-unstable.rofi;

        extraConfig = {
          display-drun = "launch";
          display-window = "switch";
          scroll-method = 1;
        };

        modes = [
          "drun"
          "window"
        ];

        plugins = [ pkgs-unstable.rofi-calc ];

        terminal = cfg.terminal.package.meta.mainProgram;

        # cSpell:words rasi
        theme = import ./theme.rasi.nix {
          inherit cfg;
          inherit (config.lib.formats) rasi;
        };
      };

      mixins.desktopEnvironment.hyprland.launcher = {
        processName = "rofi";

        mkDrunCommand =
          {
            icons ? false,
            ...
          }:
          custom.lib.mkCommand [
            "rofi"
            "-show drun"
            (lib.optional icons "-show-icons")
          ];

        mkDmenuCommand =
          {
            location ? null,
            search ? true,
            width ? null,
            height ? null,
            x ? null,
            y ? null,
            extraArgs ? [ ],
            ...
          }:
          let
            locationMap = {
              "center" = "center";
              "top_left" = "northwest";
              "top" = "north";
              "top_right" = "northeast";
              "right" = "east";
              "bottom_right" = "southeast";
              "bottom" = "south";
              "bottom_left" = "southwest";
              "left" = "northwest";
            };
            translateLocation =
              location: "location: ${locationMap.${location}}; anchor: ${locationMap.${location}};";
            windowTheme =
              lib.pipe
                [
                  (lib.optional (location != null) (translateLocation location))
                  (lib.optional (width != null) "width: ${toString width}px;")
                  (lib.optional (height != null) "height: ${toString height}px;")
                  (lib.optional (x != null) "x-offset: ${toString x}px;")
                  (lib.optional (y != null) "y-offset: ${toString y}px;")
                ]
                [
                  lib.flatten
                  (lib.concatStringsSep " ")
                  (opts: if (opts != "") then "window { ${opts} }" else "")
                ];
            # cSpell:words inputbar
            inputbarTheme =
              lib.pipe
                [
                  (lib.optional (!search) "enabled: false;")
                ]
                [
                  lib.flatten
                  (lib.concatStringsSep " ")
                  (opts: if (opts != "") then "inputbar { ${opts} }" else "")
                ];
            themeString =
              lib.pipe
                [
                  (lib.optional (windowTheme != "") windowTheme)
                  (lib.optional (inputbarTheme != "") inputbarTheme)
                ]
                [
                  lib.flatten
                  (lib.concatStringsSep " ")
                ];
          in
          custom.lib.mkCommand [
            "rofi"
            "-dmenu"
            (lib.optional (themeString != "") "-theme-str \"${themeString}\"")
            extraArgs
          ];
      };
    };
}
