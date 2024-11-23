{ lib, hostname, username, overlays, ... }:

{
  imports = [
    ( lib.path.append ./. "${username}/${hostname}.nix" )
  ];

  # Set args inherited from mkHomeConfiguration
  home = {
    username = username;
    homeDirectory = "/home/${username}";
  };
  nixpkgs.overlays = overlays;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
