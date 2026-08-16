{ mkHyprlandModule, ... }:
{ lib, config, ... }:
let
  inherit (config.mixins.desktopEnvironment.hyprland.style) opacity;
  inherit (config.custom.theme) fonts;
  inherit (config.schemes) scheme;
  inherit (scheme) ansi;
in
mkHyprlandModule {
  programs.kitty = {
    font = fonts.terminal;

    quickAccessTerminalConfig = {
      background_opacity = opacity.active;
    };

    settings = {
      cursor_shape = "beam";

      cursor = "#${scheme.foreground.normal.hex}";
      background = "#${scheme.background.normal.hex}";
      foreground = "#${scheme.foreground.normal.hex}";
    }
    // (lib.concatMapAttrs (name: color: {
      "color${toString (lib.fromHexString name)}" = "#${color.hex}";
    }) ansi);
  };
}
