{
  lib,
  config,
  pkgs-hyprland,
  utility,
  ...
}:
let
  bin.rofi = lib.getExe config.programs.rofi.package;
in
utility.custom.mkHyprlandModule config {
  config =
    let
      cfg = config.windowManager.hyprland.custom;
    in
    lib.mkIf (cfg.launcher.type == "rofi") {
      programs.rofi = {
        enable = true;
        package = pkgs-hyprland.rofi;

        extraConfig = {
          show-icons = true;
          display-drun = "launch";
          scroll-method = 1;
        };

        modes = [
          "drun"
          "window"
        ];

        plugins = [ pkgs-hyprland.rofi-calc ];

        terminal = lib.getExe cfg.terminal.package;

        # cSpell:words rasi
        theme = import ./theme.rasi.nix {
          inherit cfg;
          inherit (config.lib.formats) rasi;
        };
      };

      windowManager.hyprland.custom.launcher = {
        processName = "rofi";

        mkDrunCommand = _: "${bin.rofi} -show drun";

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
          lib.pipe
            [
              "${bin.rofi} -dmenu"
              (lib.optional (themeString != "") "-theme-str \"${themeString}\"")
              extraArgs
            ]
            [
              lib.flatten
              (lib.concatStringsSep " ")
            ];
      };
    };
}
