{ mkDefaultHyprlandModule, ... }:
{ lib, config, ... }:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
in
mkDefaultHyprlandModule { dir = ./.; } {
  mixins.desktopEnvironment.hyprland.launcher.type = "rofi";

  wayland.windowManager.hyprland.settings =
    let
      inherit (cfg.binds) mods;
      inherit (lib.generators) mkLuaInline;

      trimmedProcessName = lib.substring 0 15 cfg.launcher.processName; # maximum process name length is 15 characters
      drunCommand = cfg.launcher.mkDrunCommand {
        icons = true;
      };

      command = "pkill --exact \\\"${trimmedProcessName}\\\" || ${drunCommand}";
    in
    {
      bind = [
        {
          _args = [
            "${mods.main} + R"
            (mkLuaInline "hl.dsp.exec_cmd(\"${command}\")")
          ];
        }
        {
          _args = [
            "${mods.main} + ${mods.main}_L"
            (mkLuaInline "hl.dsp.exec_cmd(\"${command}\")")
            { release = true; }
          ];
        }
      ];
    };
}
