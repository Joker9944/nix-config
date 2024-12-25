{ inputs, utility }:

{ system, hostname, usernames, overlays, nixosModules }: with inputs.nixpkgs.lib; let

  hostsPath = ../hosts;
  usersPath = ../users;

  usersNixosModulePaths = map ( username: userNixosModulePath username ) usernames;
  userNixosModulePath = username: path.append usersPath "${username}/nixos.nix";

in nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs utility hostname overlays;
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      # TODO find a way to configure this somewhere else
      config.allowUnfree = true;
    };
  };

  modules = [ hostsPath ] ++ nixosModules ++ usersNixosModulePaths;
}
