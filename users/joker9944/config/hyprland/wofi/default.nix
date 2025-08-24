/**
  * Covers:
  *  - app launcher
  *  - clipboard history
*/
{
  lib,
  config,
  pkgs,
  pkgs-hyprland,
  utility,
  ...
}:
let
  inherit (cfg.binds) mods;
  cfg = config.windowManager.hyprland.custom;
  pkg.wl-clipboard = pkgs-hyprland.wl-clipboard;
  bin = {
    pkill = "${pkgs.procps}/bin/pkill";
    wl-paste = "${pkg.wl-clipboard}/bin/wl-paste";
    wl-copy = "${pkg.wl-clipboard}/bin/wl-copy";
    cliphist = "${config.services.cliphist.package}/bin/cliphist";
    wofi = "${config.programs.wofi.package}/bin/wofi";
  };
in
utility.custom.mkHyprlandModule config {
  home.packages = [ pkg.wl-clipboard ]; # Wayland clipboard utilities

  services.cliphist = {
    enable = true;
    package = pkgs-hyprland.cliphist;
  };

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
      lib.concatStringsSep " " (
        [ "${bin.wofi} --dmenu" ]
        ++ lib.optional (location != null) "--location ${location}"
        ++ lib.optional (!search) "--define hide_search=true"
        ++ lib.optional (width != null) "--width ${toString width}"
        ++ lib.optional (height != null) "--height ${toString height}"
        ++ lib.optional (x != null) "--xoffset ${toString x}"
        ++ lib.optional (y != null) "--yoffset ${toString y}"
        ++ extraArgs
      );
  };

  wayland.windowManager.hyprland.settings = lib.mkIf config.programs.wofi.enable {
    exec-once = [
      "${bin.wl-paste} --type text --watch ${bin.cliphist} store"
    ];

    bindr = [
      "${mods.main}, SUPER_L, exec, ${bin.pkill} --exact \".wofi-wrapped\" || ${bin.wofi}"
    ];

    bind = [
      "${mods.main}, R, exec, ${bin.wofi}"
      "${mods.utility}, V, exec, ${bin.cliphist} list | ${
        cfg.launcher.mkDmenuCommand { }
      } | ${bin.cliphist} decode | ${bin.wl-copy}"
    ];
  };

  services.dunst.settings.global.dmenu = lib.mkIf config.programs.wofi.enable (
    cfg.launcher.mkDmenuCommand { }
  );
}
