/**
  GTK theming utilities for generating CSS from color schemes.
  Includes support for adw-gtk3 theme customization.
*/
{ libUtil, ... }@args:
libUtil.mkLibNamespace {
  context = ./.;
  inherit args;
}
