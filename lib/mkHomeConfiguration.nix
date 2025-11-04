{
  inputs,
  homeModules,
}:
nixosSystem:
{
  context ? ./..,
  username,
  ...
}@args:
let
  inherit (inputs.nixpkgs) lib;
  inherit (nixosSystem._module) specialArgs;

  osConfig = nixosSystem.config;

  commonModulePath = ../users/common;
  userModulePath = lib.path.append context "users/${username}";
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit (nixosSystem) pkgs;

  extraSpecialArgs = {
    inherit (specialArgs) inputs utility;
    inherit osConfig;

    custom = lib.recursiveUpdate specialArgs.custom {
      config = args;
    };
  }
  // (lib.mapAttrs (
    name: _: nixosSystem._module.args.${name}
  ) osConfig.custom.nixpkgsCompat.additionalNixpkgsInstances);

  modules = [
    commonModulePath
    userModulePath
  ]
  ++ homeModules;
}
