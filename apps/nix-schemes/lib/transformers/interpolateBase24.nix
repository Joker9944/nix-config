{ lib, custom, ... }:
{
  lightenWeight ? 0.2,
  paletteOverrides ? { },
}:
scheme: colorLib:
let
  inherit (scheme) palette;
  colorRatios = lib.zipListsWith (a: b: (b - a) / 255);
  adjust =
    color: ratios:
    lib.pipe ratios [
      (lib.zipListsWith (dec: ratio: dec + 255 * ratio) color)
      (lib.map custom.math.round)
      (lib.map (colorLib.clamp 0 255))
      (dec: colorLib.mkColor dec)
    ];
in
if scheme.system == "base24" then
  scheme
else
  {
    system = "base24";

    palette =
      let
        base10 = adjust palette.base00.dec (
          lib.map (n: -n) (colorRatios palette.base00.dec palette.base01.dec)
        );
      in
      {
        inherit base10;
        base11 = adjust base10.dec (lib.map (n: -n) (colorRatios palette.base01.dec palette.base02.dec));
        base12 = palette.base08.lighten lightenWeight;
        base13 = palette.base09.lighten lightenWeight;
        base14 = palette.base0B.lighten lightenWeight;
        base15 = palette.base0C.lighten lightenWeight;
        base16 = palette.base0D.lighten lightenWeight;
        base17 = palette.base0E.lighten lightenWeight;
      }
      // paletteOverrides;
  }
