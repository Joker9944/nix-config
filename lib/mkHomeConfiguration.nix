/**
  Build a standalone home-manager configuration for a user.
  Inherits pkgs and specialArgs from the associated NixOS configuration.

  # Type

  ```
  mkHomeConfiguration :: { nixosConfigurations :: nixosConfiguration } -> {
    context :: path?,
    username :: string,
    additionalModules :: [module]?,
    ...
  } -> homeConfiguration
  ```

  # Arguments

  First argument (partial application):
  - `nixosConfigurations`: The NixOS configuration to inherit from

  Second argument:
  - `context`: Base path for user modules (default: flake root)
  - `username`: User name, used to find modules at `users/<username>`
  - `additionalModules`: Extra modules to include

  # Example

  ```nix
  mkHomeConfiguration { nixosConfigurations = self.nixosConfigurations.my-host; } {
    username = "my-user";
  }
  ```
*/
{
  flake,
  lib,
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
  ++ (lib.attrValues flake.homeModules)
  ++ additionalModules;
}
