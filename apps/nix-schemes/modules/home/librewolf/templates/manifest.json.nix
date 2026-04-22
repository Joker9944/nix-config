# https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/manifest.json/theme#colors
cfg:
let
  inherit (cfg) scheme;
  inherit (scheme) palette;
in
builtins.toJSON {
  manifest_version = 2;
  version = "1.0.0";
  inherit (scheme) name author;
  browser_specific_settings.gecko.id = cfg.addonId;
  theme =
    if cfg.overrides.theme == null then
      {
        colors = {
          frame = "rgb(${palette.base01.rgb})"; # active frame background
          frame_inactive = "rgb(${palette.base00.rgb})"; # inactive frame background
          tab_line = "rgb(${palette.base01.rgb})"; # tab border
          tab_background_text = "rgb(${palette.base05.rgb})"; # general tab text
          toolbar = "rgb(${palette.base00.rgb})"; # navigation bar background
          toolbar_text = "rgb(${palette.base05.rgb})"; # navigation bar text
          toolbar_field = "rgb(${palette.base01.rgb})"; # navigation fields background -> URL bar
          toolbar_field_text = "rgb(${palette.base05.rgb})"; # navigation bar fields text
          toolbar_field_border_focus = "rgb(${scheme.accent.rgb})"; # focused element
          popup = "rgb(${palette.base00.rgb})"; # menu background
          popup_border = "rgb(${palette.base01.rgb})"; # menu border
          popup_text = "rgb(${palette.base05.rgb})";
        };
      }
    else
      cfg.overrides.theme;
}
