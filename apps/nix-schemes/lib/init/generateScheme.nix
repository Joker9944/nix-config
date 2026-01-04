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
  };

  transform =
    prevScheme: transformFunction:
    let
      currScheme = lib.recursiveUpdate prevScheme (transformFunction prevScheme self);
    in
    currScheme
    // {
      transform = transform currScheme;
    };
in
transform modifiedScheme (_: _: { })
