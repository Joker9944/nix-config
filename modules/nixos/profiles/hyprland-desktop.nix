{ flake, ... }:
{
  imports = [ flake.nixosModules.profiles-desktop ];

  mixins = {
    desktopEnvironment.hyprland.enable = true;
    displayManager.regreet.enable = true;
  };
}
