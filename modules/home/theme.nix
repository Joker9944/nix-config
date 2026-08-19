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
    kitty
    librewolf
    vicinae
  ];

  config =
    let
      cfg = config.custom.theme;
    in
    {
      # Only the generics whose name is itself a classification; `serif` / `sansSerif` are content
      # decisions and stay in `users/mixins/fonts.nix`. `terminal` leads because it is the Nerd
      # Font build, a superset — demoting it costs icon glyphs for generic consumers.
      fonts.fontconfig.defaultFonts = {
        monospace = [
          cfg.fonts.terminal.name
          cfg.fonts.monospace.name
        ];
        emoji = [ cfg.fonts.emoji.name ];
      };

      schemes.gtk = {
        inherit (cfg.gtk) accent;

        # Only override when the theme names a color: `mkAccentsFromColor` collapses all
        # nine accents onto it, which a palette-derived theme must keep distinct.
        overrides.accent = lib.mkIf (cfg.accent != null) (_: config.schemes.scheme.accent);
      };
    };
}
