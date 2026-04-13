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
              name = "aerial-photo-of-brown-mountains.jpg";
              path = custom.assets.aerial-photo-of-brown-mountains;
            }
            {
              name = "an-aerial-view-of-a-city-at-night.jpg";
              path = custom.assets.an-aerial-view-of-a-city-at-night;
            }
          ]}";
        }
      ];
    };
  };
}
