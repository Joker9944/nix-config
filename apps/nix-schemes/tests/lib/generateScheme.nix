{ lib, libSchemes, ... }:
let
  vendored = ../../vendor/schemes;

  schemeSystems = lib.pipe vendored [
    builtins.readDir
    lib.attrNames
  ];

  slugsOf =
    schemeSystem:
    lib.pipe (vendored + "/${schemeSystem}") [
      builtins.readDir
      lib.attrNames
      (lib.map (lib.removeSuffix ".nix"))
    ];

  paletteSize = {
    base16 = 16;
    base24 = 24;
  };

  # Validates the vendored data rather than the constructed scheme: `fromHex` is lazy
  # per channel, so a bad hex reaching it aborts evaluation inside `builtins.fromTOML`,
  # which `tryEval` cannot catch and which names no scheme. Checking the raw strings
  # keeps every failure reportable.
  malformed = lib.concatMap (
    schemeSystem:
    lib.pipe (slugsOf schemeSystem) [
      (lib.filter (
        schemeSlug:
        let
          scheme = import (vendored + "/${schemeSystem}/${schemeSlug}.nix");
        in
        scheme.system or null != schemeSystem
        || !(builtins.elem (scheme.variant or null) [
          "light"
          "dark"
        ])
        || !(lib.isString (scheme.name or null) && lib.isString (scheme.author or null))
        || lib.length (lib.attrNames scheme.palette) != paletteSize.${schemeSystem}
        || !(lib.all (hex: lib.isString hex && builtins.match "#[0-9A-Fa-f]{6}" hex != null) (
          lib.attrValues scheme.palette
        ))
      ))
      (lib.map (schemeSlug: "${schemeSystem}/${schemeSlug}"))
    ]
  ) schemeSystems;

  gruvbox = libSchemes.generateScheme "base16" "gruvbox-dark-hard";
in
{
  testGenerateSchemeMetadata = {
    expr = {
      inherit (gruvbox) system name variant;
    };
    expected = {
      system = "base16";
      name = "Gruvbox dark, hard";
      variant = "dark";
    };
  };

  testGenerateSchemePalette = {
    expr = gruvbox.palette.base00.hex;
    expected = "1D2021";
  };

  testGenerateSchemeAllVendoredSchemesAreComplete = {
    expr = malformed;
    expected = [ ];
  };
}
