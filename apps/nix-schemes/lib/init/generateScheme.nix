{
  inputs,
  lib,
  libSchemes,
  ...
}:
base: slug:
let
  scheme = libSchemes.fromYaml "${base}-${slug}" "${inputs.schemes}/${base}/${slug}.yaml";

  palette = lib.pipe scheme.palette [
    (lib.mapAttrs (_: hex: libSchemes.fromHex hex))
    (lib.mapAttrs (_: dec: libSchemes.mkColor dec))
  ];

  modifiedScheme = {
    inherit (scheme)
      system
      name
      author
      variant
      ;
    inherit palette;
  };

  transform =
    prevScheme: transformFunction:
    let
      currScheme = lib.recursiveUpdate prevScheme (transformFunction prevScheme libSchemes);
    in
    currScheme
    // {
      transform = transform currScheme;
    };
in
transform modifiedScheme (_: _: { })
