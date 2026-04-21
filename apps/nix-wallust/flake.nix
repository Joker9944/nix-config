{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

    in
    {
      homeManagerModules =
        let
          moduleNames = lib.pipe ./modules [
            builtins.readDir
            builtins.attrNames
            (lib.filter (lib.hasSuffix ".nix"))
            (map (lib.removeSuffix ".nix"))
          ];
          modules = lib.genAttrs moduleNames (name: import ./modules/${name}.nix);
        in
        modules
        // {
          default = {
            imports = builtins.attrValues modules;
          };
        };
    };
}
