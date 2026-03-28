{ flakeLib, ... }:
let
  inherit (flakeLib.obfuscation) obfuscate deobfuscate;
in
{
  # Test that obfuscate produces expected output
  testObfuscateSimple = {
    expr = obfuscate 42 "ABC";
    expected = [
      107 # 'A' (65) XOR 42 = 107
      104 # 'B' (66) XOR 42 = 104
      105 # 'C' (67) XOR 42 = 105
    ];
  };

  # Test that deobfuscate produces expected output
  testDeobfuscateSimple = {
    expr = deobfuscate 42 [
      107 # 107 XOR 42 = 'A' (65)
      104 # 104 XOR 42 = 'B' (66)
      105 # 105 XOR 42 = 'C' (67)
    ];
    expected = "ABC";
  };

  # Test roundtrip: deobfuscate(obfuscate(x)) == x
  testRoundtripSimple = {
    expr = deobfuscate 42 (obfuscate 42 "hello");
    expected = "hello";
  };

  testRoundtripWithSpaces = {
    expr = deobfuscate 123 (obfuscate 123 "hello world");
    expected = "hello world";
  };

  testRoundtripSpecialChars = {
    expr = deobfuscate 255 (obfuscate 255 "test@123!");
    expected = "test@123!";
  };

  testRoundtripEmpty = {
    expr = deobfuscate 1 (obfuscate 1 "");
    expected = "";
  };

  # Test with mask 0 (identity)
  testObfuscateMaskZero = {
    expr = deobfuscate 0 (obfuscate 0 "test");
    expected = "test";
  };
}
