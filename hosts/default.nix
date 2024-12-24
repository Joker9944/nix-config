{ lib, config, pkgs, hostname, overlays, ... }:

let
  locale = {
    us = "us";
    de = "de";
    en_US = "en_US.UTF-8";
    de_CH = "de_CH.UTF-8";
  };
in {
  # Import matching host modules
  imports = [
    ( lib.path.append ./. hostname )
  ];

  # Set args inherited from mkNixosConfiguration
  nixpkgs.overlays = overlays;
  networking.hostName = hostname;

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

  # Enable automatic upgrades
  system.autoUpgrade = {
    enable = true;
    persistent = true;
    flake = "github:Joker9944/nix-config";
    dates = "daily";
  };

  # Set default session environment variables
  environment.sessionVariables = {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
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

  # Set default desktop environment
  services.xserver = {
    enable = true;

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

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
    git

    # Utilities
    curl
    wget
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
