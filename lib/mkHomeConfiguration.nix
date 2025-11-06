{
  inputs,
  homeModules,
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
  inherit (inputs.nixpkgs) lib;
  inherit (nixosConfigurations._module) specialArgs;

  osConfig = nixosConfigurations.config;

  commonModulePath = ../users/common;
  userModulePath = lib.path.append context "users/${username}";
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit (nixosConfigurations) pkgs;

  extraSpecialArgs = {
    inherit (specialArgs) inputs utility;
    inherit osConfig;

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
