_:
{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = with inputs.nix-schemes.homeModules; [
    gtk
    librewolf
  ];

  config =
    let
      cfg = config.custom.theme;
    in
    {
      schemes = {
        gtk = {
          inherit (cfg.gtk) accent;

          # Only override when the theme names a color: `mkAccentsFromColor` collapses all
          # nine accents onto it, which a palette-derived theme must keep distinct.
          overrides.accent = lib.mkIf (cfg.accent != null) (_: config.schemes.scheme.accent);
        };

        librewolf.accent = config.schemes.scheme.accent;
      };
    };
}
