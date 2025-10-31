{
  pkgs-unstable,
  config,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  programs.nextcloud.package = pkgs-unstable.nextcloud-client;
}
