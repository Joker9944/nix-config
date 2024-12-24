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
      url = "github:budimanjojo/talhelper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }: let

    nixosModules = [
      inputs.sops-nix.nixosModules.sops
    ];

    homeModules = [
      inputs.home-manager-xdg-autostart.homeManagerModules.xdg-autostart
      inputs.sops-nix.homeManagerModules.sops
    ];

    overlays = [
      inputs.talhelper.overlays.default
    ];

    utility = import ./lib/utility.nix nixpkgs.lib;
    mkNixosConfiguration = import ./lib/mkNixosConfiguration.nix {
      inherit inputs utility nixosModules;
    };
    mkHomeConfiguration = import ./lib/mkHomeConfiguration.nix {
      inherit inputs utility homeModules;
    };
  in inputs.flake-utils.lib.eachDefaultSystem ( system: let pkgs = nixpkgs.legacyPackages.${ system }; in {

    packages = {
      firefox-profile-switcher-connector = pkgs.callPackage ./pkgs/firefox-profile-switcher-connector.nix { };
    };

  }) // {

    overlays = {
      firefox-profile-switcher-connector = final: prev: { inherit ( self.packages.${ prev.system } ) firefox-profile-switcher-connector; };
    };

    nixosConfigurations.HAL9000 = mkNixosConfiguration {
      system = "x86_64-linux";
      hostname = "HAL9000";
      usernames = [ "joker9944" ];
      overlays = overlays ++ ( utility.attrsToValuesList self.overlays );
    };

    homeConfigurations."joker9944@HAL9000" = mkHomeConfiguration {
      system = "x86_64-linux";
      hostname = "HAL9000";
      username = "joker9944";
      overlays = overlays ++ ( utility.attrsToValuesList self.overlays );
    };

  };
}
