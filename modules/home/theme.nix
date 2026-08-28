_:
{
  inputs,
  config,
  ...
}:
{
  imports = [ inputs.nix-schemes.homeModules.default ];

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

        accents.mode = if cfg.gtk.uniformAccents then "uniform" else "palette";
      };
    };
}
