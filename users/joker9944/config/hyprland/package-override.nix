{
  pkgs-hyprland,
  config,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  programs.nextcloud-client.package = pkgs-hyprland.nextcloud-client;
}
