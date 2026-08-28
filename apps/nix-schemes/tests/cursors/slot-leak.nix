{
  pkgs,
  flake,
  runCommand,
  python3Packages,
  resvg,
}:
let
  libSchemes = flake.lib.libSchemes.init pkgs;

  red = hex: libSchemes.color.mkColor (libSchemes.color.fromHex hex);

  # Nine reds a human can still tell apart, all with green == blue so that every blend
  # between them keeps the property `slot-leak.py` asserts on.
  colors = {
    fill = red "FF5050";
    outline = red "4A0000";
    shadow = red "990000";
    accent = red "FF0000";
    accentAlt = red "C22020";
    negative = red "FFA0A0";
    positive = red "D14545";
    info = red "E85D5D";
    neutral = red "6B1010";
  };

  # Every slot is supplied here, so the scheme contributes nothing but the theme name.
  scheme = libSchemes.mkScheme {
    source = flake.schemes.base16.dracula // {
      name = "SlotLeak";
    };
  };

  theme = libSchemes.mkCursorTheme { inherit scheme colors; };
in
runCommand "cursor-slot-leak"
  {
    nativeBuildInputs = [
      (python3Packages.python.withPackages (ps: [ ps.pillow ]))
      resvg
    ];
  }
  ''
    python3 ${./slot-leak.py} ${theme}/share/icons/${theme.themeName}
    touch $out
  ''
