{ inputs, utility, homeModules }:

{ system, hostname, username, overlays }: with inputs.nixpkgs.lib; let
  usersPath = ../users;
  customHomeManagerModulesPath = ../modules/home;

  customHomeManagerModulesPaths = ( map ( filename: path.append customHomeManagerModulesPath filename ) ( utility.listFiles customHomeManagerModulesPath ));

in inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  extraSpecialArgs = {
    inherit inputs utility overlays hostname username;
  };
  modules = [ usersPath ] ++ homeModules ++ customHomeManagerModulesPaths;
}
