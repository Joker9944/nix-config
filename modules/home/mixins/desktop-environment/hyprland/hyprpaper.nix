{ mkHyprlandModule, inputs, ... }:
{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  assets = inputs.nix-assets.packages.${pkgs.stdenv.hostPlatform.system};
in
mkHyprlandModule {
  services.hyprpaper = {
    enable = true;
    package = pkgs-unstable.hyprpaper;

    settings = lib.mkDefault {
      splash = false;

      wallpaper = [
        {
          monitor = "";
          timeout = 60 * 30;
          path = "${pkgs-unstable.linkFarm "wallpapers" [
            {
              name = "utopia-2.jpg";
              path = assets.utopia-2;
            }
            {
              name = "utopia-4.jpg";
              path = assets.utopia-4;
            }
          ]}";
        }
      ];
    };
  };
}
