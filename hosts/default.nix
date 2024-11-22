{ config, pkgs, ... }:

let
  locale = {
    us = "us";
    de = "de";
    en_US = "en_US.UTF-8";
    de_CH = "de_CH.UTF-8";
  };
in {
  # Enable experimental flake support and experimental nix command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set default bootloader settings
  boot.loader = {
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = true;
      consoleMode = "max";
      configurationLimit = 10;
    };
  };

  # Set default localisation
  time.timeZone = "Europe/Zurich";
  i18n = with locale; {
    defaultLocale = en_US;
    extraLocaleSettings = {
      LC_ADDRESS = de_CH;
      LC_IDENTIFICATION = de_CH;
      LC_MONETARY = de_CH;
      LC_MEASUREMENT = de_CH;
      LC_NAME = de_CH;
      LC_NUMERIC = de_CH;
      LC_PAPER = de_CH;
      LC_TELEPHONE = de_CH;
      LC_TIME = de_CH;
    };
  };

  # Set deault keymap
  services.xserver.xkb = with locale; {
    layout = de;
    variant = us;
  };

  console.keyMap = locale.us;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable default programs
  programs = {
    firefox.enable = true;
    _1password-gui.enable = true;
    # Disable nano and switch to vim as default
    nano.enable = false;
    vim.enable = true;
    vim.defaultEditor = true;
  };

  environment.systemPackages = with pkgs; [
    # Clients
    home-manager

    # Utilities
    curl
    wget
    git
  ];

  # Enable networking by default
  networking.networkmanager.enable = true;

  # Enable PipeWire by default
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
