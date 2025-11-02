{
  pkgs-unstable,
  config,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  programs.nextcloud-client.package = pkgs-unstable.nextcloud-client;
  services.nextcloud-client.package = pkgs-unstable.nextcloud-client;
}
