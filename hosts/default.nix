{
  lib,
  utility,
  config,
  pkgs,
  hostname,
  overlays,
  ...
}: let
  locale = {
    us = "us";
    de = "de";
    en_US = "en_US.UTF-8";
    de_CH = "de_CH.UTF-8";
  };
in {
  imports =
    [
      (lib.path.append ./. hostname) # Import matching host modules
    ]
    ++ (utility.listFilesRelative ./common);

  # Set args inherited from mkNixosConfiguration
  nixpkgs.overlays = overlays;
  networking.hostName = hostname;

  # Enable experimental flake support and experimental nix command
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Enable automatic upgrades
  system.autoUpgrade = {
    enable = lib.mkDefault true;
    persistent = true;
    flake = "github:Joker9944/nix-config";
    dates = lib.mkDefault "*-*-* 04:00:00 UTC"; # 1 hour after github actions nix flake update
  };

  # Enable automatic nix store garbage collection
  nix.gc = {
    automatic = lib.mkDefault true;
    persistent = true;
    dates = lib.mkDefault "weekly";
  };

  # Enable automatic nix store optimization
  nix.optimise = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault ["weekly"];
  };

  # Set default session environment variables
  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
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

  # Set default keymap
  services.xserver.xkb = with locale; {
    layout = lib.mkDefault de;
    variant = lib.mkDefault us;
  };

  console.useXkbConfig = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set default desktop environment
  common.desktopEnvironment.gnome.enable = lib.mkDefault true;

  # Enable default programs
  programs = {
    firefox.enable = lib.mkDefault true;
    _1password-gui.enable = lib.mkDefault true;
    ffmpeg.enable = lib.mkDefault true;
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

  # Enable Tailscale by default
  services.tailscale.enable = true;

  # Enable cups by default
  services.printing = {
    enable = lib.mkDefault true;
    drivers = [pkgs.epson-escpr];
  };

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
