{ mkMixinModule, ... }:
{
  lib,
  config,
  ...
}:
mkMixinModule "telegram" {
  config =
    let
      inherit (config.programs.telegram) package;
      cfg = config.mixins.desktopEnvironment.hyprland;
    in
    {
      programs.telegram.enable = true;

      xdg.autostart.entries = [
        "${package}/share/applications/org.telegram.desktop.desktop"
      ];

      wayland.windowManager.hyprland.settings = lib.mkMerge [
        (cfg.mkAppWorkspace {
          id = "telegram";
          class = "org.telegram.desktop";
          launch = cfg.mkAppEntryCommand {
            inherit package;
            name = "org.telegram.desktop.desktop";
          };
          silent = true;
        })
        {
          window_rule = [
            {
              name = "telegram-media";
              match = {
                class = "org.telegram.desktop";
                title = "Media viewer";
              };
              content = "photo";
            }
          ];
        }
      ];
    };
}
