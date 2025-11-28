{
  pkgs-hyprland,
  config,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  home.packages = [ pkgs-hyprland.udiskie ];

  services = {
    udiskie = {
      enable = true;
      package = pkgs-hyprland.udiskie;

      tray = "never";
    };
  };
}
