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
let
  inherit (inputs.nixpkgs) lib;

  hostsPath = ../hosts;
  usersPath = ../users;

  usersNixosModulePaths = lib.map userNixosModulePath usernames;
  userNixosModulePath = username: lib.path.append usersPath "${username}/nixos.nix";
in
lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs utility;

    custom = {
      config = args;

      assets = inputs.nix-assets.packages.${system} // {
        inherit (inputs.nix-assets) palettes;
      };
    };
  };

  modules = [
    hostsPath
    (_: { nixpkgs.overlays = overlays; })
  ]
  ++ nixosModules
  ++ usersNixosModulePaths;
}
