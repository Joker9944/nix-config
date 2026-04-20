{ mkHyprlandModule, ... }:
{
  lib,
  pkgs-hyprland,
  custom,
  ...
}:
mkHyprlandModule {
  services.hyprpaper = {
    enable = true;
    package = pkgs-hyprland.hyprpaper;

    settings = lib.mkDefault {
      splash = false;

      wallpaper = [
        {
          monitor = "";
          timeout = 60 * 30;
          path = "${pkgs-hyprland.linkFarm "wallpapers" [
            {
              name = "utopia-2.jpg";
              path = custom.assets.utopia-2;
            }
            {
              name = "utopia-4.jpg";
              path = custom.assets.utopia-4;
            }
          ]}";
        }
      ];
    };
  };
}
