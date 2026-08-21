/**
  Assert that a package provides a desktop entry and return its ID.

  Turns a wrong or renamed entry into a failure instead of a launcher that silently does
  nothing. A package that declares `desktopItems` is checked during evaluation; for any
  other the returned string carries a check derivation in its context, so the entry is
  verified when the file it is written into gets built.

  # Type

  ```
  requireDesktopFile :: { pkgs :: attrset, package :: package, name :: string ? } -> string
  ```

  # Arguments

  - `pkgs`: package set the check derivation is built from
  - `package`: package expected to provide the entry
  - `name` (optional): entry ID including the `.desktop` suffix, defaults to the package name

  # Example

  ```nix
  requireDesktopFile {
    inherit pkgs;
    package = pkgs.signal-desktop;
  }
  => "signal.desktop"
  ```
*/
{ libSelf, lib, ... }:
{
  pkgs,
  package,
  name ? "${lib.getName package}.desktop",
  ...
}:
let
  declared = libSelf.lookupDesktopFiles package;

  check = pkgs.runCommandLocal "assert-desktop-file-${name}" { } ''
    if [ ! -e "${package}/share/applications/${name}" ]; then
      echo "Desktop entry \"${name}\" not found in ${lib.getName package}. Available:" >&2
      ls "${package}/share/applications" >&2
      exit 1
    fi
    touch "$out"
  '';
in
if declared == [ ] then
  lib.strings.addContextFrom "${check}" name
else if lib.elem name declared then
  name
else
  throw "Desktop entry \"${name}\" not found in ${lib.getName package}. Available: ${lib.concatStringsSep ", " declared}"
