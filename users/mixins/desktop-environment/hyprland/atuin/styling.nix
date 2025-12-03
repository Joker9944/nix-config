{ config, custom, ... }:
custom.lib.mkHyprlandModule config {
  programs.atuin =
    let
      inherit (config.windowManager.hyprland.custom.style) pallet;
      themeName = "home-assistant";
    in
    {
      # TODO setting theming on ice for the moment since theming is not implemented well at the moment.
      # https://github.com/atuinsh/atuin/issues/2663
      # settings.theme.name = themeName;

      themes.${themeName} = {
        theme.name = themeName;

        colors = {
          AlertInfo = pallet.cyan.dull.hex;
          AlertWarn = pallet.yellow.dull.hex;
          AlertError = pallet.red.dull.hex;
          Annotation = pallet.magenta.dull.hex;
          Base = pallet.cursor.hex;
          Guidance = pallet.black.bright.hex;
          Important = pallet.functional.focus.hex;
          Title = pallet.highlights.text.hex;
        };
      };
    };
}
