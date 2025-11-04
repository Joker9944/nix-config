{
  inputs,
  utility,
  overlays,
  nixosModules,
}:
{
  context ? ./..,
  system,
  hostname,
  usernames,
  ...
}@args:
let
  inherit (inputs.nixpkgs) lib;

  commonModulePath = ../hosts/common;
  hostModulePath = lib.path.append context "hosts/${hostname}";
  userModulePaths = lib.map (username: lib.path.append context "users/${username}/nixos") usernames;
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
    commonModulePath
    hostModulePath
    (_: { nixpkgs.overlays = overlays; })
  ]
  ++ nixosModules
  ++ userModulePaths;
}
