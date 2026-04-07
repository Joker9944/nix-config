{
  mixins = {
    fonts.enable = true;
    keymap.enable = true;
    localization.enable = true;
    nix.enable = true;

    desktopEnvironment.hyprland.enable = true;
    displayManager.regreet.enable = true;

    boot = {
      enable = true;
      windowsSupport.enable = true;
    };

    hardware = {
      disko.enable = true;
      nvidia.enable = true;
    };

    networking = {
      hosts.enable = true;
      networkmanager.enable = true;
    };

    programs = {
      _1password.enable = true;
      ffmpeg.enable = true;
      git.enable = true;
      gnupg.enable = true;
      home-manager.enable = true;
      steam.enable = true;
      utilities.enable = true;
      vim.enable = true;
    };

    services = {
      maintenance.enable = true;
      pipewire.enable = true;
      printing.enable = true;
      tailscale.enable = true;
    };

    virtualisation = {
      docker.enable = true;
    };
  };
}
