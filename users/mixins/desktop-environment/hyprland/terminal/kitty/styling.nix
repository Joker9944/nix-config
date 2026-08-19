{ mkHyprlandModule, ... }:
{ config, ... }:
let
  inherit (config.mixins.desktopEnvironment.hyprland.style) opacity;
  inherit (config.custom.theme) fonts;
in
mkHyprlandModule {
  programs.kitty = {
    font = fonts.terminal;

    quickAccessTerminalConfig = {
      background_opacity = opacity.active;
    };

    settings.cursor_shape = "beam";
  };

  schemes.kitty.enable = true;
}
