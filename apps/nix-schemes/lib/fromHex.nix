{ lib, ... }:
hex:
lib.pipe hex [
  (lib.removePrefix "#")
  lib.stringToCharacters
  (chars: lib.genList (i: lib.concatStrings (lib.sublist (i * 2) 2 chars)) (lib.length chars / 2))
  (lib.map lib.fromHexString)
]
