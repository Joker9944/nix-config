{
  description = "NixOS flake";

  inputs = {
    # nix pkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nix helpers
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-xdg-autostart.url = "github:Zocker1999NET/home-manager-xdg-autostart/main";
    sops-nix = {
      url = "github:Mic92/sops-nix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils/main";
    disko = {
      url = "github:nix-community/disko/v1.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager/trunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-math.url = "github:xddxdd/nix-math/master";
    nix-std.url = "github:chessai/nix-std/master";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    lib = nixpkgs.lib;

    nixosModules =
      [
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
      ]
      ++ (lib.mapAttrsToList (_: value: value) self.nixosModules);

    homeModules =
      [
        inputs.home-manager-xdg-autostart.homeManagerModules.xdg-autostart
        inputs.sops-nix.homeManagerModules.sops
        inputs.plasma-manager.homeManagerModules.plasma-manager
      ]
      ++ (lib.mapAttrsToList (_: value: value) self.homeModules);

    overlays = lib.mapAttrsToList (_: value: value) self.overlays;

    utility = {
      custom = import ./lib/utility.nix lib;
      math = inputs.nix-math.lib.math;
      std = inputs.nix-std.lib;
    };
    mkNixosConfiguration = import ./lib/mkNixosConfiguration.nix {
      inherit inputs utility;
    };
    mkHomeConfiguration = import ./lib/mkHomeConfiguration.nix {
      inherit inputs utility;
    };
  in
    inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = {
        firefox-profile-switcher-connector = pkgs.callPackage ./pkgs/firefox-profile-switcher-connector.nix {};
        vscode-extensions.streetsidesoftware.code-spell-checker-swiss-german = pkgs.callPackage ./pkgs/vscode-extensions.streetsidesoftware.code-spell-checker-swiss-german.nix {};
      };

      devShells.default = pkgs.mkShell {
        name = "flake-dev";

        packages = with pkgs; [
          alejandra
          home-manager
          sops
          age
          gnome-tweaks
          dconf-editor
        ];
      };

      formatter = pkgs.alejandra;
    })
    // {
      overlays = {
        firefox-profile-switcher-connector = final: prev: {inherit (self.packages.${prev.system}) firefox-profile-switcher-connector;};
        vscode-extensions-streetsidesoftware-code-spell-checker-swiss-german = final: prev: {
          vscode-extensions =
            prev.vscode-extensions
            // {
              streetsidesoftware = prev.vscode-extensions.streetsidesoftware // {inherit (self.packages.${prev.system}.vscode-extensions.streetsidesoftware) code-spell-checker-swiss-german;};
            };
        };
      };

      nixosModules = utility.custom.importFiles ./modules/nixos;
      homeModules = utility.custom.importFiles ./modules/home;

      nixosConfigurations.HAL9000 = mkNixosConfiguration {
        inherit overlays nixosModules;
        system = "x86_64-linux";
        hostname = "HAL9000";
        usernames = ["joker9944"];
      };

      nixosConfigurations.wintermute = mkNixosConfiguration {
        inherit overlays nixosModules;
        system = "x86_64-linux";
        hostname = "wintermute";
        usernames = ["joker9944"];
      };

      homeConfigurations."joker9944@HAL9000" = mkHomeConfiguration {
        inherit overlays homeModules;
        system = "x86_64-linux";
        hostname = "HAL9000";
        username = "joker9944";
      };

      homeConfigurations."joker9944@wintermute" = mkHomeConfiguration {
        inherit overlays homeModules;
        system = "x86_64-linux";
        hostname = "wintermute";
        username = "joker9944";
      };
    };
}
