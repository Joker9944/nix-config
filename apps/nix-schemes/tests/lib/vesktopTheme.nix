{ lib, libSchemes, ... }:
let
  schemeOf = system: slug: libSchemes.mkScheme { source = libSchemes.generateScheme system slug; };

  themeOf =
    scheme:
    import ../../modules/home/vesktop/theme {
      inherit lib;
      colors = import ../../modules/home/vesktop/theme/anchors.nix scheme;
    };

  dracula = schemeOf "base24" "dracula";
  dark = themeOf dracula;
  upcast = themeOf (schemeOf "base16" "gruvbox-dark-hard");
  light = themeOf (schemeOf "base16" "one-light");

  stepsOf =
    ramp: theme:
    lib.pipe theme [
      lib.attrNames
      (lib.filter (name: lib.head (lib.splitString "-" name) == ramp))
      (lib.map (name: lib.toInt (lib.elemAt (lib.splitString "-" name) 1)))
      (lib.sort (a: b: a < b))
    ];

  named = [
    "primary"
    "brand"
    "red"
    "green"
    "yellow"
    "orange"
    "blue"
    "teal"
    "white"
    "black"
  ];

  # Linear interpolation never leaves the box its two anchors span, so every channel of
  # every step has to sit between the channels of the anchors bracketing it. A step that
  # escapes means the bracketing search picked the wrong pair.
  overshoots =
    theme:
    let
      anchors = import ../../modules/home/vesktop/theme/anchors.nix dracula;
      bounded =
        ramp:
        let
          anchored = lib.pipe anchors [
            lib.attrNames
            (lib.filter (name: lib.head (lib.splitString "-" name) == ramp))
            (lib.map (name: lib.toInt (lib.elemAt (lib.splitString "-" name) 1)))
            (lib.sort (a: b: a < b))
          ];
        in
        lib.filter (
          step:
          let
            below = lib.filter (a: a <= step) anchored;
            above = lib.filter (a: a >= step) anchored;
          in
          below != [ ]
          && above != [ ]
          && !(within (at ramp (lib.last below)) (at ramp (lib.head above)) (at ramp step))
        ) (stepsOf ramp theme);

      at = ramp: step: theme."${ramp}-${toString step}";

      within =
        low: high: color:
        lib.all
          (
            index: bracketed (lib.elemAt low.dec index) (lib.elemAt high.dec index) (lib.elemAt color.dec index)
          )
          [
            0
            1
            2
          ];

      # `mix` rounds, so a channel may land a unit outside the open interval.
      bracketed =
        a: b: c:
        c >= (lib.min a b) - 1 && c <= (lib.max a b) + 1;
    in
    lib.filter (ramp: bounded ramp != [ ]) named;
in
{
  # Discord numbers every ramp `H`, `H+30`, `H+60` over the hundreds 100 to 800, plus 900
  # and the irregular 345. A missing step is a variable Discord reads and we never set, so
  # that slice of the UI silently keeps its stock color.
  testVesktopThemeStepsAreComplete = {
    expr = lib.pipe named [
      (lib.map (ramp: lib.nameValuePair ramp (lib.length (stepsOf ramp dark))))
      lib.listToAttrs
    ];
    expected = {
      primary = 27;
      brand = 26;
      red = 26;
      green = 26;
      yellow = 26;
      orange = 26;
      blue = 26;
      teal = 26;
      white = 26;
      black = 26;
    };
  };

  # The legacy grey ramp is indexed rather than numbered, and runs as long as primary.
  testVesktopThemeDontuseIsIndexed = {
    expr = stepsOf "dontuse" dark;
    expected = lib.range 0 26;
  };

  testVesktopThemeDontuseTracksPrimary = {
    expr = [
      (dark."dontuse-0" == dark."primary-100")
      (dark."dontuse-1" == dark."primary-130")
      (dark."dontuse-26" == dark."primary-900")
    ];
    expected = [
      true
      true
      true
    ];
  };

  # The contract of an anchor is that it lands exactly, unmixed.
  testVesktopThemeAnchorsLandExactly = {
    expr = lib.pipe (import ../../modules/home/vesktop/theme/anchors.nix dracula) [
      (lib.filterAttrs (name: color: dark.${name}.hex != color.hex))
      lib.attrNames
    ];
    expected = [ ];
  };

  testVesktopThemeAnchorsFollowScheme = {
    expr = dark."primary-600".hex;
    expected = dracula.palette.base00.hex;
  };

  testVesktopThemeInterpolationStaysInsideAnchors = {
    expr = overshoots dark;
    expected = [ ];
  };

  # A base16 source is upcast on construction, so it reaches every step a base24 one does.
  testVesktopThemeUpcastCoversSameKeys = {
    expr = lib.attrNames upcast == lib.attrNames dark;
    expected = true;
  };

  testVesktopThemeLightCoversSameKeys = {
    expr = lib.attrNames light == lib.attrNames dark;
    expected = true;
  };

  testVesktopThemeValuesAreColors = {
    expr = lib.pipe dark [
      (lib.filterAttrs (_: color: !libSchemes.color.isColor color))
      lib.attrNames
    ];
    expected = [ ];
  };
}
