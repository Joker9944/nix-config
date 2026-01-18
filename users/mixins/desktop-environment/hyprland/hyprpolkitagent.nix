{
  pkgs-hyprland,
  config,
  custom,
  ...
}:
custom.lib.mkHyprlandModule config {
  services.hyprpolkitagent = {
    enable = true;
    package = pkgs-hyprland.hyprpolkitagent;
  };
}
