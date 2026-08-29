/**
  Build a standalone home-manager configuration for a user.
  Inherits pkgs from the associated NixOS configuration and exposes it as `osConfig`.

  # Type

  ```
  mkHomeConfiguration :: { nixosConfigurations :: nixosConfiguration } -> {
    username :: string,
    additionalModules :: [module]?,
    ...
  } -> homeConfiguration
  ```

  # Arguments

  First argument (partial application):
  - `nixosConfigurations`: The NixOS configuration to inherit from

  Second argument:
  - `username`: User name, selecting `homeModules.users-<username>`
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
  inputs,
  ...
}:
{
  nixosConfigurations,
}:
{
  username,
  additionalModules ? [ ],
  ...
}:
let
  osConfig = nixosConfigurations.config;
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit (nixosConfigurations) pkgs;

  # osConfig is a lazy reference to the paired NixOS configuration and is read in
  # import position, so it cannot be an inline module arg.
  extraSpecialArgs = { inherit osConfig; };

  modules = [
    flake.homeModules.mixins
    flake.homeModules.theme # TODO
    flake.homeModules."users-${username}"
    {
      _module.args = lib.mapAttrs (
        name: _: nixosConfigurations._module.args.${name}
      ) osConfig.custom.pkgs;

      home = {
        inherit username;
        homeDirectory = "/home/${username}";
      };
    }
  ]
  ++ (lib.pipe flake.homeModules [
    (lib.filterAttrs (name: _: lib.hasPrefix "public-" name))
    lib.attrValues
  ])
  ++ additionalModules;
}
