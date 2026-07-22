{ mkMixinModule, ... }:
{ pkgs, ... }:
mkMixinModule "kde-plasma" {
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kate
  ];

  services.xserver = {
    enable = true;

    desktopManager.plasma6.enable = true;
  };
}
