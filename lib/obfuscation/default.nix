{ lib, ... }:
let
  ascii = import ./ascii-table.nix lib;
in
{
  obfuscate =
    mask: clear: lib.map (char: lib.bitXor (ascii.toInt char) mask) (lib.stringToCharacters clear);

  deobfuscate =
    mask: obfuscated: lib.concatStrings (lib.map (int: ascii.toChar (lib.bitXor int mask)) obfuscated);
}
