{ mkMixinModule, ... }:
{ config, ... }:
mkMixinModule "signal" {
  config =
    let
      inherit (config.programs.signal) package;
      cfg = config.mixins.desktopEnvironment.hyprland;
    in
    {
      programs.signal.enable = true;

      wayland.windowManager.hyprland.settings = cfg.mkAppWorkspace {
        id = "signal";
        key = "G";
        class = "signal";
        launch = cfg.mkAppEntryCommand {
          inherit package;
          name = "signal.desktop";
        };
      };
    };
}
