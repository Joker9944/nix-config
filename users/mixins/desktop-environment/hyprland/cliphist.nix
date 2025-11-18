{
  lib,
  config,
  pkgs-hyprland,
  utility,
  ...
}:
let
  cfg = config.windowManager.hyprland.custom;
in
utility.custom.mkHyprlandModule config {
  home.packages = [ pkgs-hyprland.wl-clipboard ]; # Wayland clipboard utilities

  services.cliphist = {
    enable = true;
    package = pkgs-hyprland.cliphist;
  };

  wayland.windowManager.hyprland.settings.bind =
    let
      inherit (cfg.binds) mods;
      bin = {
        wl-copy = lib.getExe' pkgs-hyprland.wl-clipboard "wl-copy";
        cliphist = lib.getExe pkgs-hyprland.cliphist;
      };
      dmenuCommand = cfg.launcher.mkDmenuCommand { };
    in
    [
      "${mods.utility}, V, exec, ${bin.cliphist} list | ${dmenuCommand} | ${bin.cliphist} decode | ${bin.wl-copy}"
    ];
}
