{ mkMixinModule, ... }:
{
  osConfig,
  pkgs-unstable,
  ...
}:
mkMixinModule "lutris" {
  programs.lutris = {
    enable = true;

    package = pkgs-unstable.lutris;
    extraPackages = with pkgs-unstable; [
      mangohud
      winetricks
      gamemode
      umu-launcher
    ];

    protonPackages = [ pkgs-unstable.proton-ge-bin ];

    steamPackage = osConfig.programs.steam.package;
  };
}
