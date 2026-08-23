{
  description = "Nix color scheme library with base16/base24 support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    flake-utils.url = "github:numtide/flake-utils/main"; # cSpell:ignore numtide
    nix-math = {
      url = "github:xddxdd/nix-math/master"; # cSpell:ignore xddxdd
      inputs.nixpkgs.follows = "nixpkgs";
    };
    util-lib = {
      url = ../util-lib;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    schemes = {
      url = "github:tinted-theming/schemes/spec-0.11";
      flake = false;
    };
    adw-colors = {
      url = "github:lassekongo83/adw-colors/main"; # cSpell:ignore lassekongo
      flake = false;
    };
    # Pinned to a tag rather than a branch: `cursors/Breeze/src/svg` has taken three commits
    # since July 2024, and the alternative is re-resolving a 44 MB tarball nightly.
    breeze = {
      url = "github:KDE/breeze/v6.7.4";
      flake = false;
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      inherit (inputs.util-lib.lib) libUtil;
    in
    lib.recursiveUpdate
      (inputs.flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          apps = import ./apps {
            inherit
              inputs
              lib
              system
              pkgs
              ;
          };

          checks = {
            libTests = pkgs.callPackage ./tests/lib {
              inherit libUtil;
              flake = self;
            };

            cursorIdentity = pkgs.callPackage ./tests/cursors/identity.nix {
              inherit (inputs) breeze;
            };

            cursorSlotLeak = pkgs.callPackage ./tests/cursors/slot-leak.nix {
              flake = self;
            };
          };
        }
      ))
      {
        lib.libSchemes = lib.fix (
          libSelf:
          import ./lib {
            inherit
              inputs
              lib
              libSelf
              libUtil
              ;
            libMath = inputs.nix-math.lib.math;

            flake = self;
          }
        );

        schemes = lib.pipe ./vendor/schemes [
          builtins.readDir
          lib.attrNames
          (lib.map (schemeSystem: {
            name = schemeSystem;
            value = lib.pipe schemeSystem [
              (lib.path.append ./vendor/schemes)
              builtins.readDir
              lib.attrNames
              (lib.map (lib.removeSuffix ".nix"))
            ];
          }))
          lib.listToAttrs
          (lib.mapAttrs (
            schemeSystem: schemes:
            lib.pipe schemes [
              (lib.map (schemeSlug: {
                name = schemeSlug;
                value = self.lib.libSchemes.generateScheme schemeSystem schemeSlug;
              }))
              lib.listToAttrs
            ]
          ))
        ];

        nixosModules =
          let
            modules = {
              scheme = import ./modules/global/scheme.nix self;
              cursors = import ./modules/global/cursors.nix self;
              icons = import ./modules/global/icons.nix self;
              regreet = import ./modules/nixos/regreet.nix self;
            };
          in
          {
            default = {
              imports = lib.attrValues modules;
            };
          }
          // modules;

        homeModules =
          let
            modules = {
              scheme = import ./modules/global/scheme.nix self;
              cursors = import ./modules/global/cursors.nix self;
              icons = import ./modules/global/icons.nix self;
              gtk = import ./modules/home/gtk.nix self;
              kitty = import ./modules/home/kitty.nix self;
              librewolf = import ./modules/home/librewolf self;
              vicinae = import ./modules/home/vicinae.nix self;
            };
          in
          {
            default = {
              imports = lib.attrValues modules;
            };
          }
          // modules;
      };
}
