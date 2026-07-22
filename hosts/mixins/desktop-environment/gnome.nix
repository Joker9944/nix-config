{ mkMixinModule, ... }:
{ pkgs, ... }:
mkMixinModule "gnome" {
  services = {
    xserver = {
      enable = true;

      desktopManager.gnome.enable = true;
    };

    gnome.gnome-browser-connector.enable = true;
  };

  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-connections
    epiphany # web browser
  ];
}
