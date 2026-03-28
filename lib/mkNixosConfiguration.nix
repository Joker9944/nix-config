/**
  Build a NixOS configuration for a host.
  Automatically includes host-specific modules, user modules, and flake modules.

  # Type

  ```
  mkNixosConfiguration :: {
    context :: path?,
    system :: string,
    hostname :: string,
    usernames :: [string],
    additionalModules :: [module]?,
    ...
  } -> nixosConfiguration
  ```

  # Arguments

  - `context`: Base path for host/user modules (default: flake root)
  - `system`: System architecture (e.g., "x86_64-linux")
  - `hostname`: Host name, used to find modules at `hosts/<hostname>`
  - `usernames`: List of users, modules loaded from `users/<username>/nixos`
  - `additionalModules`: Extra modules to include

  # Example

  ```nix
  mkNixosConfiguration {
    system = "x86_64-linux";
    hostname = "my-host";
    usernames = [ "my-user" ];
  }
  ```
*/
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
