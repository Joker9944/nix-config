{
  lib,
  homeModules,
  ...
}:
{
  nixosConfigurations,
}:
{
  context ? ./..,
  username,
  additionalModules ? [ ],
  ...
}@args:
let
  inherit (nixosConfigurations._module) specialArgs;
  inherit (specialArgs) inputs;

  osConfig = nixosConfigurations.config;

  commonModulePath = ../users/mixins;
  userModulePath = lib.path.append context "users/${username}";
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit (nixosConfigurations) pkgs;

  extraSpecialArgs = {
    inherit inputs osConfig;

    custom = lib.recursiveUpdate specialArgs.custom {
      config = args;
    };
  }
  // (lib.mapAttrs (
    name: _: nixosConfigurations._module.args.${name}
  ) osConfig.custom.nixpkgsCompat.additionalNixpkgsInstances);

  modules = [
    commonModulePath
    userModulePath
  ]
  ++ homeModules
  ++ additionalModules;
}
