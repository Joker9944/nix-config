{
  inputs,
  lib,
  self,
  ...
}:
base: slug:
let
  scheme = self.fromYaml "${base}-${slug}" "${inputs.schemes}/${base}/${slug}.yaml";

  palette = lib.pipe scheme.palette [
    (lib.mapAttrs (_: hex: self.fromHex hex))
    (lib.mapAttrs (_: dec: self.mkColor dec))
  ];

  modifiedScheme = {
    inherit (scheme)
      system
      name
      author
      variant
      ;
    inherit palette;

    translations.ansi = {
      "0" = palette.base01;
      "8" = palette.base01;
      "1" = palette.base08;
      "9" = palette.base08;
      "2" = palette.base0B;
      "A" = palette.base0B;
      "3" = palette.base09;
      "B" = palette.base09;
      "4" = palette.base0D;
      "C" = palette.base0D;
      "5" = palette.base0E;
      "D" = palette.base0E;
      "6" = palette.base0C;
      "E" = palette.base0C;
      "7" = palette.base06;
      "F" = palette.base06;
    };
  }
  // lib.optionalAttrs (base == "base24") {
    translations.ansi = {
      "0" = palette.base01;
      "8" = palette.base02;
      "1" = palette.base08;
      "9" = palette.base12;
      "2" = palette.base0B;
      "A" = palette.base14;
      "3" = palette.base09;
      "B" = palette.base13;
      "4" = palette.base0D;
      "C" = palette.base16;
      "5" = palette.base0E;
      "D" = palette.base17;
      "6" = palette.base0C;
      "E" = palette.base15;
      "7" = palette.base06;
      "F" = palette.base07;
    };
  };

  mkOverridable =
    base: overridePredicate:
    let
      newBase = lib.recursiveUpdate base (overridePredicate base self);
    in
    newBase
    // {
      override = mkOverridable newBase;
    };
in
mkOverridable modifiedScheme (_: _: { })
