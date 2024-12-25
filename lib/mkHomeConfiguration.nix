{ inputs, utility }:

{ system, hostname, username, overlays, homeModules }: let

  usersPath = ../users;
  
in inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  extraSpecialArgs = {
    inherit inputs utility overlays hostname username;
  };
  modules = [ usersPath ] ++ homeModules;
}
