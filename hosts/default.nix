{ config, pkgs, ... }:

{
  # Enable experimental flake support and experimental nix command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable networking by default
  networking.networkmanager.enable = true;

  # Set default localisation
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "de_CH.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ALL = "en_US.UTF-8";
  };

  # Set deault keymap
  services.xserver.xkb = {
    layout = "de";
    variant = "us";
  };

  console.keyMap = "us";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable default programs
  programs = {
    firefox.enable = true;
    _1password-gui.enable = true;
  };

  # Add default packages
  environment.systemPackages = with pkgs; [
    vim
    wget
  ];
}
