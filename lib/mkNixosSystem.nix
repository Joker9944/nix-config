{ inputs, libUtility, overlays }:

hostname:

{ system, users }: with inputs.nixpkgs.lib; let
  hostsModulesPath = ../hosts;
  nixosModulesPath = ../modules;
  usersPath = ../users;

  userModulesPath = username: path.append usersPath "${username}/${hostname}.nix";
  nixosModules = ( map ( name: path.append nixosModulesPath name ) ( libUtility.listFiles nixosModulesPath ));

  usersModules = listToAttrs ( map ( username: {
    name = username;
    value = import ( userModulesPath username );
  }) users );
in nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs libUtility hostname overlays;
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      # TODO find a way to configure this somewhere else
      config.allowUnfree = true;
    };
  };

  modules = [
    hostsModulesPath

    inputs.home-manager.nixosModules.home-manager {
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users = usersModules;
    }
  ] ++ nixosModules;
}
