{
  lib,
  config,
  pkgs-hyprland,
  utility,
  ...
}:
let
  bin.wofi = lib.getExe config.programs.wofi.package;
in
utility.custom.mkHyprlandModule config {
  config =
    let
      cfg = config.windowManager.hyprland.custom;
    in
    lib.mkIf (cfg.launcher.type == "wofi") {
      programs.wofi = {
        enable = true;
        package = pkgs-hyprland.wofi;

        settings = {
          ### Behavior ###
          show = "drun";
          allow_images = true;
          prompt = "Search...";
          hide_scroll = true;
        };

        style = import ./style.css.nix { inherit cfg; };
      };

      windowManager.hyprland.custom.launcher = {
        processName = ".wofi-wrapped";

        mkDrunCommand = _: "${bin.wofi} --show drun";

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
          utility.custom.mkCommand [
            "${bin.wofi} --dmenu"
            (lib.optional (location != null) "--location ${location}")
            (lib.optional (!search) "--define hide_search=true")
            (lib.optional (width != null) "--width ${toString width}")
            (lib.optional (height != null) "--height ${toString height}")
            (lib.optional (x != null) "--xoffset ${toString x}")
            (lib.optional (y != null) "--yoffset ${toString y}")
            extraArgs
          ];
      };
    };
}
