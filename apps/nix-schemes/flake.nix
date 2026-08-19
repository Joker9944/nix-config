{
  description = "Nix color scheme library with base16/base24 support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils/main"; # cSpell:ignore numtide
    schemes = {
      url = "github:tinted-theming/schemes/spec-0.11";
      flake = false;
    };
    nix-math = {
      url = "github:xddxdd/nix-math/master"; # cSpell:ignore xddxdd
      inputs.nixpkgs.follows = "nixpkgs";
    };
    base24-gen = {
      url = "github:psyclyx/base24-gen/main"; # cSpell:ignore psyclyx
      flake = false;
    };
    adw-colors = {
      url = "github:lassekongo83/adw-colors/main"; # cSpell:ignore lassekongo
      flake = false;
    };
    util-lib = {
      url = "path:../util-lib";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
    in
    lib.recursiveUpdate
      (inputs.flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          packages = {
            base24-gen = pkgs.callPackage "${inputs.base24-gen}/package.nix" { };
          };

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

            base24-gen = {
              type = "app";
              program = lib.getExe self.packages.${system}.base24-gen;
              inherit (self.packages.${system}.base24-gen) meta;
            };
          };

          checks = {
            libTests = pkgs.callPackage ./tests/lib {
              inherit (inputs.util-lib.lib) libUtil;
              flake = self;
            };
          };
        }
      ))
      {
        lib.libSchemes = lib.fix (
          libSelf:
          import ./lib {
            inherit inputs lib libSelf;
            inherit (inputs.util-lib.lib) libUtil;
            libMath = inputs.nix-math.lib.math;

            flake = self;
          }
        );

        schemes = lib.pipe inputs.schemes [
          builtins.readDir
          lib.attrNames
          (lib.filter (lib.hasPrefix "base"))
          (lib.map (filename: {
            name = filename;
            value = lib.pipe filename [
              (filename: "${inputs.schemes}/${filename}")
              builtins.readDir
              lib.attrNames
              (lib.filter (lib.hasSuffix ".yaml"))
              (lib.map (lib.removeSuffix ".yaml"))
            ];
          }))
          lib.listToAttrs
          (lib.mapAttrs (
            base: schemes:
            lib.pipe schemes [
              (lib.map (schemeSlug: {
                name = schemeSlug;
                value = {
                  convert = pkgs: (self.lib.libSchemes.init pkgs).generateScheme base schemeSlug;
                };
              }))
              lib.listToAttrs
            ]
          ))
        ];

        nixosModules = {
          default = self.nixosModules.scheme;

          scheme = import ./modules/global/scheme.nix self;
          regreet = import ./modules/nixos/regreet.nix self;
        };

        homeModules = {
          default = self.homeModules.scheme;

          scheme = import ./modules/global/scheme.nix self;
          gtk = import ./modules/home/gtk.nix self;
          kitty = import ./modules/home/kitty.nix self;
          librewolf = import ./modules/home/librewolf self;
          vicinae = import ./modules/home/vicinae.nix self;
        };
      };
}
