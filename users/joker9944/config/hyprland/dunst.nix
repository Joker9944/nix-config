{
  config,
  pkgs-hyprland,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  services.dunst = {
    enable = true;
    package = pkgs-hyprland.dunst;
  };
}
