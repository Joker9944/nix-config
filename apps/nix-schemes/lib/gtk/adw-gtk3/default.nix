/**
  adw-gtk3 theme CSS generation utilities.
  Generate custom CSS to apply color schemes to GTK3 and GTK4 applications
  using the adw-gtk3 theme.
*/
{ libUtil, ... }@args:
libUtil.mkLibNamespace {
  context = ./.;
  inherit args;
}
