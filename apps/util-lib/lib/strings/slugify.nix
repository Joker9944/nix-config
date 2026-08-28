/**
  Reduce a string to a lowercase `[a-z0-9-]` identifier.

  A Latin letter carrying a diacritic is transliterated to its ASCII base; anything else
  outside `[a-z0-9]` separates, runs collapsing to a single `-` with both ends trimmed. A
  script with no ASCII equivalent — Greek, Cyrillic, CJK — is not romanised and drops out
  as a separator, so a name written entirely in one is an error rather than an empty slug.

  # Type

  ```
  slugify :: string -> string
  ```

  # Example

  ```nix
  slugify "Rosé Pine Dawn"
  => "rose-pine-dawn"
  ```
*/
{ lib, ... }:
let
  # Latin-1 Supplement and Latin Extended-A. The letters NFKD cannot decompose — ligatures,
  # strokes, thorn and eszett — are spelled out rather than dropped.
  transliterations = {
    "À" = "A";
    "Á" = "A";
    "Â" = "A";
    "Ã" = "A";
    "Ä" = "A";
    "Å" = "A";
    "Æ" = "AE";
    "Ç" = "C";
    "È" = "E";
    "É" = "E";
    "Ê" = "E";
    "Ë" = "E";
    "Ì" = "I";
    "Í" = "I";
    "Î" = "I";
    "Ï" = "I";
    "Ð" = "D";
    "Ñ" = "N";
    "Ò" = "O";
    "Ó" = "O";
    "Ô" = "O";
    "Õ" = "O";
    "Ö" = "O";
    "Ø" = "O";
    "Ù" = "U";
    "Ú" = "U";
    "Û" = "U";
    "Ü" = "U";
    "Ý" = "Y";
    "Þ" = "TH";
    "ß" = "ss";
    "à" = "a";
    "á" = "a";
    "â" = "a";
    "ã" = "a";
    "ä" = "a";
    "å" = "a";
    "æ" = "ae";
    "ç" = "c";
    "è" = "e";
    "é" = "e";
    "ê" = "e";
    "ë" = "e";
    "ì" = "i";
    "í" = "i";
    "î" = "i";
    "ï" = "i";
    "ð" = "d";
    "ñ" = "n";
    "ò" = "o";
    "ó" = "o";
    "ô" = "o";
    "õ" = "o";
    "ö" = "o";
    "ø" = "o";
    "ù" = "u";
    "ú" = "u";
    "û" = "u";
    "ü" = "u";
    "ý" = "y";
    "þ" = "th";
    "ÿ" = "y";
    "Ā" = "A";
    "ā" = "a";
    "Ă" = "A";
    "ă" = "a";
    "Ą" = "A";
    "ą" = "a";
    "Ć" = "C";
    "ć" = "c";
    "Ĉ" = "C";
    "ĉ" = "c";
    "Ċ" = "C";
    "ċ" = "c";
    "Č" = "C";
    "č" = "c";
    "Ď" = "D";
    "ď" = "d";
    "Đ" = "D";
    "đ" = "d";
    "Ē" = "E";
    "ē" = "e";
    "Ĕ" = "E";
    "ĕ" = "e";
    "Ė" = "E";
    "ė" = "e";
    "Ę" = "E";
    "ę" = "e";
    "Ě" = "E";
    "ě" = "e";
    "Ĝ" = "G";
    "ĝ" = "g";
    "Ğ" = "G";
    "ğ" = "g";
    "Ġ" = "G";
    "ġ" = "g";
    "Ģ" = "G";
    "ģ" = "g";
    "Ĥ" = "H";
    "ĥ" = "h";
    "Ħ" = "H";
    "ħ" = "h";
    "Ĩ" = "I";
    "ĩ" = "i";
    "Ī" = "I";
    "ī" = "i";
    "Ĭ" = "I";
    "ĭ" = "i";
    "Į" = "I";
    "į" = "i";
    "İ" = "I";
    "ı" = "i";
    "Ĳ" = "IJ";
    "ĳ" = "ij";
    "Ĵ" = "J";
    "ĵ" = "j";
    "Ķ" = "K";
    "ķ" = "k";
    "ĸ" = "k";
    "Ĺ" = "L";
    "ĺ" = "l";
    "Ļ" = "L";
    "ļ" = "l";
    "Ľ" = "L";
    "ľ" = "l";
    "Ŀ" = "L";
    "ŀ" = "l";
    "Ł" = "L";
    "ł" = "l";
    "Ń" = "N";
    "ń" = "n";
    "Ņ" = "N";
    "ņ" = "n";
    "Ň" = "N";
    "ň" = "n";
    "ŉ" = "n";
    "Ŋ" = "NG";
    "ŋ" = "ng";
    "Ō" = "O";
    "ō" = "o";
    "Ŏ" = "O";
    "ŏ" = "o";
    "Ő" = "O";
    "ő" = "o";
    "Œ" = "OE";
    "œ" = "oe";
    "Ŕ" = "R";
    "ŕ" = "r";
    "Ŗ" = "R";
    "ŗ" = "r";
    "Ř" = "R";
    "ř" = "r";
    "Ś" = "S";
    "ś" = "s";
    "Ŝ" = "S";
    "ŝ" = "s";
    "Ş" = "S";
    "ş" = "s";
    "Š" = "S";
    "š" = "s";
    "Ţ" = "T";
    "ţ" = "t";
    "Ť" = "T";
    "ť" = "t";
    "Ŧ" = "T";
    "ŧ" = "t";
    "Ũ" = "U";
    "ũ" = "u";
    "Ū" = "U";
    "ū" = "u";
    "Ŭ" = "U";
    "ŭ" = "u";
    "Ů" = "U";
    "ů" = "u";
    "Ű" = "U";
    "ű" = "u";
    "Ų" = "U";
    "ų" = "u";
    "Ŵ" = "W";
    "ŵ" = "w";
    "Ŷ" = "Y";
    "ŷ" = "y";
    "Ÿ" = "Y";
    "Ź" = "Z";
    "ź" = "z";
    "Ż" = "Z";
    "ż" = "z";
    "Ž" = "Z";
    "ž" = "z";
    "ſ" = "s";
    "ẞ" = "SS";
  };
in
name:
lib.pipe name [
  (builtins.replaceStrings (lib.attrNames transliterations) (lib.attrValues transliterations))
  lib.toLower
  (builtins.split "[^a-z0-9]+")
  (lib.filter (part: lib.isString part && part != ""))
  (lib.concatStringsSep "-")
  (slug: if slug == "" then throw "slugify: \"${name}\" reduces to an empty slug" else slug)
]
