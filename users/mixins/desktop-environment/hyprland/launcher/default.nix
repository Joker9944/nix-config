{
  lib,
  config,
  pkgs,
  custom,
  ...
}:
custom.lib.mkHyprlandModule config {
  imports = custom.lib.ls {
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
          drunCommand = cfg.launcher.mkDrunCommand {
            icons = true;
          };

          command = "${bin.pkill} --exact \"${trimmedProcessName}\" || ${drunCommand}";
        in
        {
          # Trigger on release so other key binds still work
          bindr = [
            "${mods.main}, SUPER_L, exec, ${command}"
          ];

          bind = [
            "${mods.main}, R, exec, ${command}"
          ];
        };
    };
}
