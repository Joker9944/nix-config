{...}: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
    ./pipewire.nix
    ./nvidia.nix
    ./docker.nix
  ];

  # Setup for dual boot with windows
  boot.loader.grub.useOSProber = true;
  time.hardwareClockInLocalTime = true;

  # Set desktop environment
  common.desktopEnvironment.gnome.enable = false;
  common.desktopEnvironment.kde-plasma.enable = true;

  programs = {
    steam.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
