{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    schemes = {
      url = "github:tinted-theming/schemes/spec-0.11";
      flake = false;
    };
    nix-math = {
      url = "github:xddxdd/nix-math/master"; # cSpell:ignore xddxdd
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
    in
    {
      lib = import ./lib {
        inherit inputs lib;

        custom = {
          inherit (inputs.nix-math.lib) math;
        };
      };

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
                convert = pkgs: (self.lib.init pkgs).generateScheme base schemeSlug;
              };
            }))
            lib.listToAttrs
          ]
        ))
      ];

      homeManagerModules = {
        default = self.homeManagerModules.scheme;

        scheme = import ./modules/home/scheme.nix self;
        gtk = import ./modules/home/gtk self;
      };
    };
}
