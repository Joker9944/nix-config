{
  config,
  pkgs-hyprland,
  custom,
  ...
}:
custom.lib.mkHyprlandModule config {
  imports = custom.lib.ls {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  config.services.dunst =
    let
      cfg = config.windowManager.hyprland.custom;
    in
    {
      enable = true;
      package = pkgs-hyprland.dunst;

      settings = {
        global = {
          ### Display ###

          follow = "mouse";

          enable_posix_regex = true;

          ### Geometry ###

          width = 500;
          height = "(0, 300)";

          origin = "top-center";
          offset = "(0, 20)";

          notification_limit = 5;

          dmenu = cfg.launcher.mkDmenuCommand { };
        };
      };
    };
}
