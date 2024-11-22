{ inputs, libUtility, overlays }:

hostname:

{ system, users }: with inputs.nixpkgs.lib; let
  hostsPath = ../hosts;
  modulesPath = ../modules;
  usersPath = ../users;

  hostModulesPath = path.append hostsPath "${hostname}/configuration.nix";
  userModulesPath = username: path.append usersPath "${username}/${hostname}.nix";
  customModules = ( map (name: path.append modulesPath name ) ( libUtility.listFiles modulesPath ));

  usersModules = listToAttrs ( map ( username: {
    name = username;
    value = import ( userModulesPath username );
  }) users );
in nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs;
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      # TODO find a way to configure this somewhere else
      config.allowUnfree = true;
    };
    inherit libUtility;
  };

  modules = [
    {
      nixpkgs.overlays = overlays;
      networking.hostName = hostname;
    }

    hostsPath
    hostModulesPath

    inputs.home-manager.nixosModules.home-manager {
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users = usersModules;
    }
  ] ++ customModules;
}
