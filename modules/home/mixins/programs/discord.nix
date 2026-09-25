{ mkMixinModule, ... }:
{ config, ... }:
mkMixinModule "discord" {
  config =
    let
      cfg = config.mixins.desktopEnvironment.hyprland;
    in
    {
      programs.vesktop.enable = true;

      wayland.windowManager.hyprland.settings = cfg.mkAppWorkspace {
        id = "discord";
        class = "vesktop";
        launch = cfg.mkAppEntryCommand {
          package = config.programs.vesktop.package;
        };
      };
    };
}
