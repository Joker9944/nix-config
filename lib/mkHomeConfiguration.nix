{
  inputs,
  utility,
  overlays,
  homeModules,
}:
osConfig:
{ system, ... }@args:
let
  usersPath = ../users;
in
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  extraSpecialArgs = {
    inherit inputs utility osConfig;

    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system overlays;
      # TODO find a way to configure this somewhere else
      config.allowUnfree = true;
    };
    pkgs-hyprland = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};

    custom = {
      config = args;

      assets = inputs.nix-assets.packages.${system} // {
        inherit (inputs.nix-assets) palettes;
      };
    };
  };

  modules = [
    usersPath
  ]
  ++ homeModules
  ++ [
    (_: {
      # TODO find a way to configure this somewhere else
      nixpkgs.overlays = overlays;
      nixpkgs.config.allowUnfree = true;
    })
  ];
}
