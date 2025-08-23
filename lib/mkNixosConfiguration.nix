{
  inputs,
  utility,
  overlays,
  nixosModules,
}:
{
  system,
  usernames,
  ...
}@args:
with inputs.nixpkgs.lib;
let
  hostsPath = ../hosts;
  usersPath = ../users;

  usersNixosModulePaths = map userNixosModulePath usernames;
  userNixosModulePath = username: path.append usersPath "${username}/nixos.nix";
in
nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs utility;

    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system overlays;
      # TODO find a way to configure this somewhere else
      config.allowUnfree = true;
    };
    pkgs-hyprland = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};

    custom = {
      config = args;

      assets = inputs.nix-assets.packages.${system};
    };
  };

  modules = [
    hostsPath
  ]
  ++ nixosModules
  ++ usersNixosModulePaths
  ++ [
    (_: {
      # TODO find a way to configure this somewhere else
      nixpkgs.overlays = overlays;
      nixpkgs.config.allowUnfree = true;
    })
  ];
}
