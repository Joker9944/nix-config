{ mkHyprlandModule, ... }:
{ pkgs-unstable, ... }:
mkHyprlandModule {
  programs.nextcloud-client.package = pkgs-unstable.nextcloud-client;
  services.nextcloud-client.package = pkgs-unstable.nextcloud-client;
}
