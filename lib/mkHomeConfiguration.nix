{ inputs, libUtility, homeModules, overlays }:

{ system, hostname, username }: let
  usersPath = ../users;
in inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  extraSpecialArgs = {
    inherit inputs libUtility overlays hostname username;
  };
  modules = [ usersPath ] ++ homeModules;
}
