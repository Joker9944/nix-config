{
  inputs,
  lib,
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
    (custom.lib.ls {
      dir = ./.;
      exclude = [ ./default.nix ];
    })
    ++ [ inputs.sops-nix.nixosModules.sops ];

  # Set args inherited from mkNixosConfiguration
  networking.hostName = custom.config.hostname;

  # import nixpkgs-unstable as module arg
  custom.nixpkgsCompat.additionalNixpkgsInstances = {
    pkgs-unstable = inputs.nixpkgs-unstable;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    substituters = lib.toList "https://nix-community.cachix.org";
    trusted-public-keys = lib.toList "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="; # cSpell:disable-line
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

  console.useXkbConfig = true;

  services = {
    # Enable cups by default
    printing = {
      enable = lib.mkDefault true;
      drivers = [ pkgs.epson-escpr ];
    };
  };

  # Enable default programs
  programs = {
    # Disable nano and switch to vim as default
    nano.enable = lib.mkDefault false;
    vim = {
      enable = lib.mkDefault true;
      defaultEditor = lib.mkDefault true;
    };
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
