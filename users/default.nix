{ lib, config, hostname, username, overlays, ... }:

let
  userSecrets = lib.path.append ./. "${ username }/secrets.yaml";
in {
  imports = [
    ( lib.path.append ./. "${ username }/${ hostname }.nix" )
  ];

  # Set args inherited from mkHomeConfiguration
  home = {
    username = username;
    homeDirectory = "/home/${ username }";
  };
  nixpkgs.overlays = overlays;

  # Enable automatic upgrades
  services.betterAutoUpgrade = {
    enable = true;
    persistent = true;
    flake = "github:Joker9944/nix-config";
    frequency = "daily";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Setup sops if user secrets file exists
  sops = lib.mkIf ( builtins.pathExists userSecrets ) {
    defaultSopsFile = userSecrets;
    age.keyFile = "${ config.xdg.configHome }/sops/age/keys.txt";
  };
}
