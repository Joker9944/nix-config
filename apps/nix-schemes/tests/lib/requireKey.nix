{ libSchemes, ... }:
let
  base = libSchemes.color.mkScheme {
    system = "base16";
    name = "Test Scheme";
    author = "tester";
    variant = "dark";
    palette.base00 = libSchemes.color.mkColor [
      0
      0
      0
    ];
  };

  scheme = base.transform (
    _: _: {
      accent = libSchemes.color.mkColor [
        180
        120
        174
      ];

      background.normal = libSchemes.color.mkColor [
        1
        2
        3
      ];
    }
  );
in
{
  testRequireKeyString = {
    expr = (libSchemes.requireKey scheme "accent").hex;
    expected = "B478AE";
  };

  testRequireKeySingletonPath = {
    expr = (libSchemes.requireKey scheme [ "accent" ]).hex;
    expected = "B478AE";
  };

  testRequireKeyNestedPath = {
    expr =
      (libSchemes.requireKey scheme [
        "background"
        "normal"
      ]).hex;
    expected = "010203";
  };

  testRequireKeyStandardKey = {
    expr = libSchemes.requireKey scheme "variant";
    expected = "dark";
  };

  testRequireKeyMissing = {
    expr = (builtins.tryEval (libSchemes.requireKey scheme "nonexistent")).success;
    expected = false;
  };

  testRequireKeyMissingNested = {
    expr =
      (builtins.tryEval (
        libSchemes.requireKey scheme [
          "background"
          "dark"
        ]
      )).success;
    expected = false;
  };
}
