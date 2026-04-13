{ mkHyprlandModule, ... }:
mkHyprlandModule {
  programs.atuin =
    #let
    #  inherit (config.mixins.desktopEnvironment.hyprland.style) palette;
    #  themeName = "home-assistant";
    #in
    {
      # TODO setting theming on ice for the moment since theming is not implemented well at the moment.
      # https://github.com/atuinsh/atuin/issues/2663
      # settings.theme.name = themeName;

      /*
        themes.${themeName} = {
          theme.name = themeName;

          colors = {
            AlertInfo = palette.cyan.dull.hex;
            AlertWarn = palette.yellow.dull.hex;
            AlertError = palette.red.dull.hex;
            Annotation = palette.magenta.dull.hex;
            Base = palette.cursor.hex;
            Guidance = palette.black.bright.hex;
            Important = palette.functional.focus.hex;
            Title = palette.highlights.text.hex;
          };
        };
      */
    };
}
