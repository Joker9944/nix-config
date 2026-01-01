{
  lib,
  config,
  custom,
  ...
}:
custom.lib.mkHyprlandModule config {
  programs.kitty =
    let
      cfg = config.windowManager.hyprland.custom.style;
      inherit (cfg) fonts opacity scheme;
      inherit (scheme.translations) ansi;
    in
    {
      font = fonts.terminal;

      quickAccessTerminalConfig = {
        background_opacity = opacity.active;
      };

      settings = {
        cursor_shape = "beam";

        cursor = scheme.named.foreground.normal.hex;
        background = scheme.named.background.normal.hex;
        foreground = scheme.named.foreground.normal.hex;
      }
      // (lib.concatMapAttrs (name: color: {
        "color${toString (lib.fromHexString name)}" = color.hex;
      }) ansi);
    };
}
