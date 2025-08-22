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
}: let
  cfg = config.desktopEnvironment.hyprland;
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
    home.packages = [pkg.wl-clipboard]; # Wayland clipboard utilities

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

      style = import ./style.css.nix {inherit cfg;};
    };

    wayland.windowManager.hyprland.settings = let
      mods = cfg.bind.mods;
    in
      lib.mkIf config.programs.wofi.enable {
        exec-once = [
          "${bin.wl-paste} --type text --watch ${bin.cliphist} store"
        ];

        bindr = [
          "${mods.main}, SUPER_L, exec, ${bin.pkill} --exact \".wofi-wrapped\" || ${bin.wofi}"
        ];

        bind = [
          "${mods.main}, R, exec, ${bin.wofi}"
          "${mods.utility}, V, exec, ${bin.cliphist} list | ${bin.wofi} --dmenu | ${bin.cliphist} decode | ${bin.wl-copy}"
        ];
      };

    services.dunst.settings.dmenu.general = lib.mkIf config.programs.wofi.enable "${bin.wofi} --dmenu";
  }
