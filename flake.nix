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
    customlib = import ./lib nixpkgs.lib;

    overlays = [
      inputs.talhelper.overlays.default
    ];
  in {
    nixosConfigurations.HAL9000 = nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
        inherit customlib;
      };
      modules = [
        { nixpkgs.overlays = overlays; }

        ./hosts/HAL9000/configuration.nix

        { programs._1password-gui.enable = true; }

        home-manager.nixosModules.home-manager {
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.joker9944 = import ./users/joker9944/HAL9000.nix;
        }
      ] ++ ( map (name: path.append ./modules name) ( customlib.listFiles ./modules ));
    };

    # TODO figure this out
    /*nixosConfigurations = nixpkgs.lib.listToAttrs (nixpkgs.lib.map (hostname: {
      "name" = hostname;
      "value" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.overlays = overlays; }

          ( nixpkgs.lib.path.append hostsDir "${hostname}/configuration.nix" )

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.joker9944 = import ./users/joker9944/nixos.nix;
          }
        ];
      };
    }) (listDirs hostsDir));*/

    # TODO figure this out
    # https://github.com/nix-community/home-manager/issues/2954
    # homeConfigurations = generateHomeConfigurations;
  };
}
