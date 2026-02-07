{
  flake,
  lib,
  inputs,
  self,
  custom,
  ...
}:
{
  context ? ./..,
  system,
  hostname,
  usernames,
  additionalModules ? [ ],
  ...
}@args:
let
  mixinsModulePath = ../hosts/mixins;
  hostModulePath = lib.path.append context "hosts/${hostname}";
  userModulePaths = lib.map (username: lib.path.append context "users/${username}/nixos") usernames;
in
lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs;

    custom = custom // {
      lib = self;
      config = args;

      assets = inputs.nix-assets.packages.${system};
    };
  };

  modules = [
    mixinsModulePath
    hostModulePath
    (_: { nixpkgs.overlays = lib.attrValues flake.overlays; })
  ]
  ++ (lib.attrValues flake.nixosModules)
  ++ userModulePaths
  ++ additionalModules;
}
