/**
  Get the names of desktop files a package provides.

  Reads `desktopItems` when the package declares them (the `copyDesktopItems` hook
  convention), otherwise falls back to reading the package's applications directory,
  which requires building the package.

  # Type

  ```
  lookupDesktopFiles :: package -> [string]
  ```

  # Example

  ```nix
  lookupDesktopFiles pkgs.firefox
  => [ "firefox.desktop" ]
  ```
*/
{ lib, ... }:
package:
let
  # `copyDesktopItems` accepts a bare item as well as a list
  items = lib.toList (package.desktopItems or [ ]);
in
if items != [ ] then
  lib.map (item: item.name or (lib.baseNameOf (toString item))) items
else
  lib.attrNames (lib.readDir "${package}/share/applications")
