{ lib, ... }:
hex:
let
  normalized = lib.removePrefix "#" hex;
in
assert lib.assertMsg (
  lib.stringLength normalized == 6
) "fromHex: expected 6-character hex string, got '${hex}'";
lib.pipe normalized [
  lib.stringToCharacters
  (chars: lib.genList (i: lib.concatStrings (lib.sublist (i * 2) 2 chars)) (lib.length chars / 2))
  (lib.map lib.fromHexString)
]
