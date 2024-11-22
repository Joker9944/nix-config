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
    # external pkgs
    talhelper = {
      url = "github:budimanjojo/talhelper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, ... }: with nixpkgs.lib; let
    libUtility = import ./lib/utility.nix nixpkgs.lib;

    overlays = [
      inputs.talhelper.overlays.default
    ];

    mkNixosSystem = import ./lib/mkNixosSystem.nix {
      inherit inputs libUtility overlays;
    };
  in {
    nixosConfigurations.HAL9000 = mkNixosSystem "HAL9000" {
      system = "x86_64-linux";
      users = [ "joker9944" ];
    };

    # TODO figure this out
    # https://github.com/nix-community/home-manager/issues/2954
    # homeConfigurations = generateHomeConfigurations;
  };
}
