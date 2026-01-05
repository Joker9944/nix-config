{
  mixins = {
    boot.enable = true;

    displayManager.enable = true;
    desktopEnvironment.hyprland.enable = true;

    networking.hosts.enable = true;

    services = {
      maintenance.enable = true;
      tailscale.enable = true;
    };

    programs = {
      _1password.enable = true;
      steam.enable = true;
    };
  };
}
