{
  description = "Root NixOS flake";

  inputs = {
    nixpkgs.url= "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    talhelper.url = "github:budimanjojo/talhelper";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: let
    hostsDir = ./hosts;
    usersDir = ./users;

    listDirs = dir: nixpkgs.lib.attrNames ( nixpkgs.lib.filterAttrs ( filename: fileType: fileType == "directory" ) ( builtins.readDir dir ) );
    listFiles = dir: nixpkgs.lib.attrNames ( nixpkgs.lib.filterAttrs ( filename: fileType: fileType == "regular" ) ( builtins.readDir dir ) );

    hostnames = listDirs hostsDir;
    usernames = listDirs usersDir;

    hostsFromUsername = username: nixpkgs.lib.map ( filename: nixpkgs.lib.removeSuffix ".nix" filename ) ( nixpkgs.lib.filter ( filename: filename != "common.nix" ) ( listFiles nixpkgs.lib.path.append usersDir username ) );

    hostsByUsers = nixpkgs.lib.listToAttrs ( nixpkgs.lib.map ( username: {
      "name" = username;
      "value" = hostsFromUsername username;
    } ) usernames);

    generateHomeConfiguration = hostname: username:  {
      "${username}@${hostname}" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${nixpkgs.hostPlatform};
        extraSpecialArgs = { inherit inputs; };
        modules = [
          (nixpkgs.lib.path.append usersDir "${username}/${hostname}.nix")
        ];
      };
    };

    generateHomeConfigurations = nixpkgs.lib.mergeAttrsList ( nixpkgs.lib.flatten ( nixpkgs.lib.mapAttrsFlatten ( username: hostname: nixpkgs.lib.map ( hostname: generateHomeConfiguration hostname username ) hostnames ) hostsByUsers ) );

    overlays = [
      inputs.talhelper.overlays.default
    ];
  in {

    nixosConfigurations.HAL9000 = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.overlays = overlays; }

        ./hosts/HAL9000/configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.joker9944 = import ./users/joker9944/HAL9000.nix;
        }
      ];
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
