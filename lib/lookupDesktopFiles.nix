/**
  Get the names of desktop files from a package's applications directory.

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
_: package: builtins.attrNames (builtins.readDir "${package}/share/applications")
