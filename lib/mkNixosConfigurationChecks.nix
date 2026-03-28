/**
  Extract flake checks from NixOS configurations.
  Groups configurations by system and creates a check for each that builds
  the system toplevel, enabling `nix flake check` to verify all configs build.

  # Type

  ```
  mkNixosConfigurationChecks :: flake -> { <system> :: { <name> :: derivation } }
  ```

  # Example

  ```nix
  mkNixosConfigurationChecks self
  => {
    x86_64-linux = {
      nixos-my-host = <derivation>;
    };
  }
  ```
*/
{ lib, ... }:
flake:
lib.pipe flake.nixosConfigurations [
  lib.attrsToList
  (builtins.groupBy (nixosConfig: nixosConfig.value.config.nixpkgs.system))
  (lib.mapAttrs (
    _: nixosConfigs:
    lib.pipe nixosConfigs [
      (lib.map (nixosConfig: {
        name = "nixos-${nixosConfig.name}";
        value = nixosConfig.value.config.system.build.toplevel;
      }))
      lib.listToAttrs
    ]
  ))
]
