/**
  Read a key from a scheme, throwing a located error when it is absent.

  Only `system`, `name`, `author`, `variant` and `palette` are guaranteed. Everything else —
  `accent`, `ansi`, the colour words added by `transformers.named` — is freeform and exists only
  if a transformer supplied it.

  # Type

  ```
  requireKey :: scheme -> ([string] | string) -> any
  ```

  # Arguments

  - `scheme`: the scheme to read from
  - `path`: an attribute path; a bare string is a one-element path

  # Example

  ```nix
  requireKey scheme "accent"
  => <color>

  requireKey scheme [ "background" "dark" ]
  => <color>
  ```
*/
{ lib, ... }:
scheme: path:
let
  attrPath = lib.toList path;

  mkError =
    consumed: value:
    let
      location = lib.optionalString (consumed != [ ]) " at \"${lib.concatStringsSep "." consumed}\"";
      detail =
        if lib.isAttrs value then
          "Available: ${lib.concatStringsSep ", " (lib.attrNames value)}."
        else
          "That is not an attribute set.";
    in
    "requireKey: scheme \"${scheme.name}\" has no \"${lib.concatStringsSep "." attrPath}\"${location}. "
    + detail
    + " Non-standard keys are added by `schemes.transformers`.";

  step =
    acc: name:
    if lib.isAttrs acc.value && acc.value ? ${name} then
      {
        value = acc.value.${name};
        consumed = acc.consumed ++ [ name ];
      }
    else
      throw (mkError acc.consumed acc.value);
in
(lib.foldl' step {
  value = scheme;
  consumed = [ ];
} attrPath).value
