{
  inputs,
  utility,
}: {
  system,
  hostname,
  username,
  overlays,
  homeModules,
}: let
  usersPath = ../users;
in
  inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.${system};
    extraSpecialArgs = {
      inherit inputs utility overlays hostname username;
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        # TODO find a way to configure this somewhere else
        config.allowUnfree = true;
      };
    };
    modules = [usersPath] ++ homeModules;
  }
