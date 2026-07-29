{
  imports = [ ./desktop.nix ];

  mixins = {
    desktopEnvironment.hyprland.enable = true;
    displayManager.regreet.enable = true;
  };
}
