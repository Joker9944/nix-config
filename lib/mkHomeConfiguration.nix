{
  inputs,
  homeModules,
}:
nixosSystem: args:
let
  inherit (inputs.nixpkgs) lib;

  usersPath = ../users;

  osConfig = nixosSystem.config;
  inherit (nixosSystem._module) specialArgs;
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
    usersPath
  ]
  ++ homeModules;
}
