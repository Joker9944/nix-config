{ lib, libSchemes, ... }:
let
  base16Source = libSchemes.generateScheme "base16" "gruvbox-dark-hard";
  base24Source = libSchemes.generateScheme "base24" "dracula";

  upcast = libSchemes.mkScheme { source = base16Source; };
  native = libSchemes.mkScheme { source = base24Source; };

  hexOf = hex: lib.toUpper (lib.removePrefix "#" hex);
in
{
  testMkSchemeReportsBase24 = {
    expr = upcast.meta.system;
    expected = "base24";
  };

  testMkSchemeSlugFollowsSource = {
    expr = upcast.meta.slug;
    expected = "gruvbox-dark-hard";
  };

  # A custom source declares no slug, so it is derived from the name
  testMkSchemeSlugDerivedForCustomSource = {
    expr =
      (libSchemes.mkScheme {
        source = {
          name = "ORCHIDLIFT LUME";
          author = "Joker9944";
          variant = "dark";
          inherit (base24Source) palette;
        };
      }).meta.slug;
    expected = "orchidlift-lume";
  };

  testMkSchemeUpcastFillsPalette = {
    expr = lib.length (lib.attrNames upcast.palette);
    expected = 24;
  };

  testMkSchemeKeepsBase24Palette = {
    expr = native.palette.base10.hex;
    expected = hexOf base24Source.palette.base10;
  };

  # The views are total: a base16 source still answers for the extended slots
  testMkSchemeViewsCoverUpcastSlots = {
    expr = upcast.named.red.bright.hex == upcast.palette.base12.hex;
    expected = true;
  };

  testMkSchemeAnsiFollowsPalette = {
    expr = native.ansi."0".hex;
    expected = native.palette.base00.hex;
  };

  testMkSchemeStatusFollowsPalette = {
    expr = native.status.error.hex;
    expected = native.palette.base08.hex;
  };

  testMkSchemeLightenWeightReachesUpcast = {
    expr =
      (libSchemes.mkScheme {
        source = base16Source;
        lightenWeight = 0;
      }).palette.base12.hex;
    expected = upcast.palette.base08.hex;
  };

  testMkSchemeAccentDefaultsToBlue = {
    expr = native.accent.hex;
    expected = native.palette.base0D.hex;
  };

  testMkSchemeAccentBySlot = {
    expr =
      (libSchemes.mkScheme {
        source = base24Source;
        accent = "base0E";
      }).accent.hex;
    expected = native.palette.base0E.hex;
  };

  testMkSchemeAccentByHex = {
    expr =
      (libSchemes.mkScheme {
        source = base24Source;
        accent = "#B478AE";
      }).accent.hex;
    expected = "B478AE";
  };

  testMkSchemeOverrideBySlot = {
    expr =
      (libSchemes.mkScheme {
        source = base24Source;
        overrides.ansi."0" = "base01";
      }).ansi."0".hex;
    expected = native.palette.base01.hex;
  };

  testMkSchemeOverrideByHex = {
    expr =
      (libSchemes.mkScheme {
        source = base24Source;
        overrides.status.error = "#00FF7F";
      }).status.error.hex;
    expected = "00FF7F";
  };

  testMkSchemeOverrideNested = {
    expr =
      (libSchemes.mkScheme {
        source = base24Source;
        overrides.named.background.dark = "base02";
      }).named.background.dark.hex;
    expected = native.palette.base02.hex;
  };

  # A palette override reaches the views derived from it
  testMkSchemeOverridePaletteReachesViews = {
    expr =
      (libSchemes.mkScheme {
        source = base24Source;
        overrides.palette.base00 = "#101010";
      }).named.background.normal.hex;
    expected = "101010";
  };

  # An overridden slot is upcast from, not around: base12 is the lightened base08
  testMkSchemeOverrideReachesDerivedSlots = {
    expr =
      (libSchemes.mkScheme {
        source = base16Source;
        overrides.palette.base08 = "#FF0000";
      }).palette.base12.hex;
    expected = "FF3333";
  };

  # The background ramp continues from the overridden base10, not the one it would derive
  testMkSchemeOverriddenBase10FeedsBase11 = {
    expr =
      (libSchemes.mkScheme {
        source = base16Source;
        overrides.palette.base10 = "#804020";
      }).palette.base11.hex;
    expected = "6C2F11";
  };

  # A slot the source lacks survives the upcast when an override supplies it
  testMkSchemeOverrideSuppliesExtendedSlot = {
    expr =
      (libSchemes.mkScheme {
        source = base16Source;
        overrides.palette.base12 = "#010203";
      }).palette.base12.hex;
    expected = "010203";
  };

  # An override replaces the color wholesale rather than merging into it
  testMkSchemeOverrideReplacesColor = {
    expr =
      (libSchemes.mkScheme {
        source = base24Source;
        overrides.ansi."0" = "#010203";
      }).ansi."0".dec;
    expected = [
      1
      2
      3
    ];
  };
}
