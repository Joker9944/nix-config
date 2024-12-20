{ inputs, libUtility, nixosModules, overlays }:

{ system, hostname, usernames }: with inputs.nixpkgs.lib; let
  hostsPath = ../hosts;
  customNixosModulesPath = ../modules/nixos;
  usersPath = ../users;

  customNixosModulesPaths = ( map ( filename: path.append customNixosModulesPath filename ) ( libUtility.listFiles customNixosModulesPath ));

  usersNixosModulePaths = map ( username: userNixosModulePath username ) usernames;
  userNixosModulePath = username: path.append usersPath "${username}/nixos.nix";

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

  modules = [ hostsPath ] ++ nixosModules ++ customNixosModulesPaths ++ usersNixosModulePaths;
}
