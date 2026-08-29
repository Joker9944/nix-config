/**
  Build a NixOS configuration for a host.
  Automatically includes host-specific modules, user modules, and flake modules.

  # Type

  ```
  mkNixosConfiguration :: {
    system :: string,
    hostname :: string,
    usernames :: [string],
    additionalModules :: [module]?,
    ...
  } -> nixosConfiguration
  ```

  # Arguments

  - `system`: System architecture (e.g., "x86_64-linux")
  - `hostname`: Host name, selecting `nixosModules.hosts-<hostname>`
  - `profile`: Role profile, selecting `nixosModules.profiles-<profile>` (optional)
  - `usernames`: List of users, selecting `nixosModules.users-<username>`
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
  ...
}:
{
  system,
  hostname,
  profile ? null,
  usernames,
  additionalModules ? [ ],
  ...
}:
lib.nixosSystem {
  inherit system;

  modules = [
    flake.nixosModules.mixins
    flake.nixosModules.theme # TODO
    flake.nixosModules."hosts-${hostname}"
    {
      # Setup function args
      nixpkgs = {
        hostPlatform = lib.mkDefault system;
        overlays = lib.attrValues flake.overlays;
      };

      networking.hostName = lib.mkDefault hostname;
    }
    ({ config, ... }: {
      custom.pkgs.pkgs-unstable = {
        input = inputs.nixpkgs-unstable;
        inherit (config.nixpkgs) config overlays;
      };
    })
  ]
  ++ (lib.optional (profile != null) flake.nixosModules."profiles-${profile}")
  ++ (lib.pipe flake.nixosModules [
    (lib.filterAttrs (name: _: lib.hasPrefix "public-" name))
    lib.attrValues
  ])
  ++ (lib.map (username: flake.nixosModules."users-${username}") usernames)
  ++ additionalModules;
}
