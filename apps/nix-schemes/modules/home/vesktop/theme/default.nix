/**
  Expand the anchor colors into every step of Discord's primitive color ramps.

  Step numbers are generated, not tabled: each ramp carries `H`, `H+30` and `H+60` for the
  hundreds 100 to 800, plus 900 and the irregular 345. `primary` adds 645. `dontuse` is a
  legacy grey ramp indexed 0 to 26 instead, positionally parallel to primary's 27 steps.

  Every ramp runs light to dark, which is the only invariant Discord's semantic layer needs —
  `.theme-dark` reads backgrounds off the dark end and text off the light end, `.theme-light`
  the other way round, so polarity needs no branch here.

  # Type

  ```
  theme :: { lib, colors } -> { "primary-600" :: color, … }
  ```
*/
{ lib, colors }:
let
  steps = lib.sort (a: b: a < b) (
    lib.concatMap (h: [
      (h * 100)
      (h * 100 + 30)
      (h * 100 + 60)
    ]) (lib.range 1 8)
    ++ [
      345
      900
    ]
  );

  primarySteps = lib.sort (a: b: a < b) (steps ++ [ 645 ]);

  # A chromatic ramp is one color bracketed by a near-white tint and a near-black shade.
  chromatic = step: color: {
    "100" = color.lighten 0.9;
    ${toString step} = color;
    "900" = color.darken 0.9;
  };

  # `white` and `black` are clamped in Discord's own ramps — white holds 100% lightness
  # through step 500, black holds 0% from step 500 — so their flat half is two equal
  # anchors rather than a case in the interpolator.
  rampAnchors = {
    primary = {
      "100" = colors."primary-130".lighten 0.4;
      "130" = colors."primary-130";
      "230" = colors."primary-230";
      "330" = colors."primary-330";
      "400" = colors."primary-400";
      "500" = colors."primary-500";
      "560" = colors."primary-560";
      "600" = colors."primary-600";
      "700" = colors."primary-700";
      "800" = colors."primary-800";
      "900" = colors."primary-800".darken 0.5;
    };

    brand = chromatic 500 colors."brand-500";
    red = chromatic 400 colors."red-400";
    green = chromatic 430 colors."green-430";
    yellow = chromatic 300 colors."yellow-300";
    orange = chromatic 300 colors."orange-300";
    blue = chromatic 345 colors."blue-345";
    teal = chromatic 430 colors."teal-430";

    white = {
      "100" = colors."white-500";
      "500" = colors."white-500";
      "900" = colors."white-500".darken 0.95;
    };

    black = {
      "100" = colors."black-500".lighten 0.9;
      "500" = colors."black-500";
      "900" = colors."black-500";
    };
  };

  expand =
    anchors:
    let
      anchored = lib.sort (a: b: a < b) (lib.map lib.toInt (lib.attrNames anchors));
      at = step: anchors.${toString step};
    in
    step:
    let
      low = lib.last (lib.filter (a: a <= step) anchored);
      high = lib.head (lib.filter (a: a >= step) anchored);
    in
    if low == high then at low else (at low).mix (at high) ((step - low) * 1.0 / (high - low));

  primary = expand rampAnchors.primary;

  ramp =
    name: stepList:
    lib.listToAttrs (
      lib.map (
        step: lib.nameValuePair "${name}-${toString step}" (expand rampAnchors.${name} step)
      ) stepList
    );
in
lib.mergeAttrsList (
  [
    (ramp "primary" primarySteps)
  ]
  ++ lib.map (name: ramp name steps) [
    "brand"
    "red"
    "green"
    "yellow"
    "orange"
    "blue"
    "teal"
    "white"
    "black"
  ]
  ++ [
    (lib.listToAttrs (
      lib.imap0 (index: step: lib.nameValuePair "dontuse-${toString index}" (primary step)) primarySteps
    ))
  ]
)
