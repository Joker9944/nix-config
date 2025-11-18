{
  lib,
  config,
  pkgs,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  imports = utility.custom.ls.lookup {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  config =
    let
      cfg = config.windowManager.hyprland.custom;
    in
    {
      windowManager.hyprland.custom.launcher.type = "rofi";

      wayland.windowManager.hyprland.settings =
        let
          inherit (cfg.binds) mods;
          bin.pkill = lib.getExe' pkgs.procps "pkill";
          trimmedProcessName = lib.substring 0 15 cfg.launcher.processName; # maximum process name length is 15 characters
          command = "${bin.pkill} --exact \"${trimmedProcessName}\" || ${cfg.launcher.mkDrunCommand { }}";
        in
        {
          bindr = [
            "${mods.main}, SUPER_L, exec, ${command}"
          ];

          bind = [
            "${mods.main}, R, exec, ${command}"
          ];
        };
    };
}
