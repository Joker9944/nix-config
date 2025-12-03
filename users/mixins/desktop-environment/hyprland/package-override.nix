{
  pkgs-unstable,
  config,
  custom,
  ...
}:
custom.lib.mkHyprlandModule config {
  programs.nextcloud-client.package = pkgs-unstable.nextcloud-client;
  services.nextcloud-client.package = pkgs-unstable.nextcloud-client;
}
