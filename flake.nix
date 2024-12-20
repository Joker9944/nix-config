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
    # external pkgs
    talhelper = {
      url = "github:budimanjojo/talhelper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ ... }: let

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

    libUtility = import ./lib/utility.nix inputs.nixpkgs.lib;
    mkNixosConfiguration = import ./lib/mkNixosConfiguration.nix {
      inherit inputs libUtility nixosModules overlays;
    };
    mkHomeConfiguration = import ./lib/mkHomeConfiguration.nix {
      inherit inputs libUtility homeModules overlays;
    };
  in {
    nixosConfigurations.HAL9000 = mkNixosConfiguration {
      system = "x86_64-linux";
      hostname = "HAL9000";
      usernames = [ "joker9944" ];
    };

    homeConfigurations."joker9944@HAL9000" = mkHomeConfiguration {
      system = "x86_64-linux";
      hostname = "HAL9000";
      username = "joker9944";
    };
  };
}
