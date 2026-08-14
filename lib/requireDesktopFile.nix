/**
  Assert that a package provides a desktop entry and return its ID.

  Turns a wrong or renamed entry into an evaluation failure instead of a launcher
  that silently does nothing.

  # Type

  ```
  requireDesktopFile :: { package :: package, name :: string ? } -> string
  ```

  # Arguments

  - `package`: package expected to provide the entry
  - `name` (optional): entry ID including the `.desktop` suffix, defaults to the package name

  # Example

  ```nix
  requireDesktopFile { package = pkgs.firefox; }
  => "firefox.desktop"
  ```
*/
{ libSelf, lib, ... }:
{
  package,
  name ? "${lib.getName package}.desktop",
  ...
}:
let
  available = libSelf.lookupDesktopFiles package;
in
if lib.elem name available then
  name
else
  throw "Desktop entry \"${name}\" not found in ${lib.getName package}. Available: ${lib.concatStringsSep ", " available}"
