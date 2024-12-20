{ inputs, libUtility, homeModules, overlays }:

{ system, hostname, username }: with inputs.nixpkgs.lib; let
  usersPath = ../users;
  customHomeManagerModulesPath = ../modules/home;

  customHomeManagerModulesPaths = ( map ( filename: path.append customHomeManagerModulesPath filename ) ( libUtility.listFiles customHomeManagerModulesPath ));

in inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  extraSpecialArgs = {
    inherit inputs libUtility overlays hostname username;
  };
  modules = [ usersPath ] ++ homeModules ++ customHomeManagerModulesPaths;
}
