{
  description = "Misc utility library";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils/main"; # cSpell:ignore numtide
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      mkLibNamespace = import ./lib/mkLibNamespace.nix { inherit lib; };
    in
    lib.recursiveUpdate
      (inputs.flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          apps = {
            test-lib = {
              type = "app";
              program = lib.getExe (
                pkgs.writeShellScriptBin "test" ''
                  nix build .#checks.${system}.libTests --no-link "$@"
                ''
              );
              meta.description = "Run lib tests";
            };
          };

          checks = {
            libTests = pkgs.callPackage ./tests/lib { flake = self; };
          };
        }
      ))
      {
        lib.libUtil = lib.fix (
          libSelf:
          mkLibNamespace {
            context = ./lib;
            args = { inherit lib libSelf; };
          }
        );
      };
}
