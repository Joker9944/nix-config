{
  description = "Root NixOS flake";

  inputs = {
    # nix pkgs
    nixpkgs.url= "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nix helpers
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-xdg-autostart.url = "github:Zocker1999NET/home-manager-xdg-autostart";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    # external pkgs
    talhelper = {
      url = "github:budimanjojo/talhelper/v3.0.19";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }: let

    lib = nixpkgs.lib;

    nixosModules = [
      inputs.sops-nix.nixosModules.sops
    ] ++ ( lib.mapAttrsToList ( _: value: value ) self.nixosModules );

    homeModules = [
      inputs.home-manager-xdg-autostart.homeManagerModules.xdg-autostart
      inputs.sops-nix.homeManagerModules.sops
    ] ++ ( lib.mapAttrsToList ( _: value: value ) self.homeModules );

    overlays = [
      inputs.talhelper.overlays.default
    ] ++ ( lib.mapAttrsToList ( _: value: value ) self.overlays );

    utility = import ./lib/utility.nix lib;
    mkNixosConfiguration = import ./lib/mkNixosConfiguration.nix {
      inherit inputs utility;
    };
    mkHomeConfiguration = import ./lib/mkHomeConfiguration.nix {
      inherit inputs utility;
    };

  in inputs.flake-utils.lib.eachDefaultSystem ( system: let pkgs = nixpkgs.legacyPackages.${ system }; in {

    packages = {
      firefox-profile-switcher-connector = pkgs.callPackage ./pkgs/firefox-profile-switcher-connector.nix { };
    };

  }) // {

    overlays = {
      firefox-profile-switcher-connector = final: prev: { inherit ( self.packages.${ prev.system } ) firefox-profile-switcher-connector; };
    };

    nixosModules = utility.importFiles ./modules/nixos;
    homeModules = utility.importFiles ./modules/home;

    nixosConfigurations.HAL9000 = mkNixosConfiguration {
      inherit overlays nixosModules;
      system = "x86_64-linux";
      hostname = "HAL9000";
      usernames = [ "joker9944" ];
    };

    homeConfigurations."joker9944@HAL9000" = mkHomeConfiguration {
      inherit overlays homeModules;
      system = "x86_64-linux";
      hostname = "HAL9000";
      username = "joker9944";
    };

  };
}
