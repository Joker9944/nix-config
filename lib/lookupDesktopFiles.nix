/**
  Get the names of the desktop files a package *declares*.

  Reads `desktopItems`, the `copyDesktopItems` hook convention. A package that installs
  its entries any other way declares nothing and yields an empty list — the names it
  ships are only readable by building it, which evaluation must not do.

  # Type

  ```
  lookupDesktopFiles :: package -> [string]
  ```

  # Example

  ```nix
  lookupDesktopFiles pkgs.signal-desktop
  => [ "signal.desktop" ]
  ```
*/
{ lib, ... }:
package:
let
  # `copyDesktopItems` accepts a bare item as well as a list
  items = lib.toList (package.desktopItems or [ ]);
in
lib.map (item: item.name or (lib.baseNameOf (toString item))) items
