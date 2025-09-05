{
  lib,
  utility,
  pkgs,
  custom,
  ...
}:
let
  locale = {
    us = "us";
    de = "de";
    en_US = "en_US.UTF-8";
    de_CH = "de_CH.UTF-8";
  };
in
{
  imports =
    (utility.custom.ls.lookup {
      dir = ./common;
    })
    ++ [
      (lib.path.append ./. custom.config.hostname) # Import matching host modules
    ];

  # Set args inherited from mkNixosConfiguration
  networking.hostName = custom.config.hostname;

  nix = {
    settings = {
      # Enable experimental flake support and experimental nix command
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Third-party Cachix
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ]; # cSpell:disable-line
    };

    # Enable automatic nix store garbage collection
    gc = {
      automatic = lib.mkDefault true;
      persistent = true;
      dates = lib.mkDefault "weekly";
    };

    # Enable automatic nix store optimization
    optimise = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault [ "weekly" ];
    };
  };

  # Enable automatic upgrades
  system.autoUpgrade = {
    enable = lib.mkDefault true;
    persistent = true;
    flake = "github:Joker9944/nix-config";
    dates = lib.mkDefault "*-*-* 04:00:00 UTC"; # 1 hour after GitHub actions nix flake update
    notify.enable = true;
  };

  # Set default session environment variables
  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  # Set default localization
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

  services = {
    # Set default keymap
    xserver.xkb = with locale; {
      layout = lib.mkDefault de;
      variant = lib.mkDefault us;
    };

    # Enable Tailscale by default
    tailscale.enable = true;

    # Enable cups by default
    printing = {
      enable = lib.mkDefault true;
      drivers = [ pkgs.epson-escpr ];
    };
  };

  console.useXkbConfig = true;

  # Set default desktop environment
  desktopEnvironment.hyprland.enable = lib.mkDefault true;

  # Enable default programs
  programs = {
    firefox.enable = lib.mkDefault true;
    _1password-gui.enable = lib.mkDefault true;
    # Disable nano and switch to vim as default
    nano.enable = lib.mkDefault false;
    vim.enable = lib.mkDefault true;
    vim.defaultEditor = lib.mkDefault true;
  };

  environment.systemPackages = with pkgs; [
    # Clients
    home-manager
    git

    # Utilities
    curl
    wget
    dig
    jq
    yq
    openssl
    pciutils
    file

    # Languages
    python3
  ];

  fonts.packages = with pkgs; [
    lato
    roboto
    texlivePackages.opensans
    texlivePackages.nunito
  ];

  # Enable networking by default
  networking.networkmanager.enable = lib.mkDefault true;

  # Enable GnuPG by default
  programs.gnupg = {
    package = pkgs.gnupg1;
    agent.enable = lib.mkDefault true;
  };

  # Enable PipeWire by default
  security.rtkit.enable = lib.mkDefault true;
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
