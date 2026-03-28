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
