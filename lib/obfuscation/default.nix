/**
  Simple XOR-based string obfuscation utilities.
  Useful for obscuring strings in configuration that shouldn't be plaintext
  but don't require real encryption.
*/
{ lib, ... }:
let
  ascii = import ./ascii-table.nix lib;
in
{
  /**
    Obfuscate a string using XOR with a mask value.

    # Type

    ```
    obfuscate :: int -> string -> [int]
    ```

    # Example

    ```nix
    obfuscate 42 "ABC"
    => [ 107 104 105 ]
    ```
  */
  obfuscate =
    mask: clear: lib.map (char: lib.bitXor (ascii.toInt char) mask) (lib.stringToCharacters clear);

  /**
    Deobfuscate a list of integers back to a string using XOR with the same mask.

    # Type

    ```
    deobfuscate :: int -> [int] -> string
    ```

    # Example

    ```nix
    deobfuscate 42 [ 107 104 105 ]
    => "ABC"
    ```
  */
  deobfuscate =
    mask: obfuscated: lib.concatStrings (lib.map (int: ascii.toChar (lib.bitXor int mask)) obfuscated);
}
