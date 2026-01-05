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
  theme.colors = {
    frame = palette.base01.hex; # active frame background
    frame_inactive = palette.base00.hex; # inactive frame background
    tab_line = palette.base01.hex; # tab border
    tab_background_text = palette.base05.hex; # general tab text
    toolbar = palette.base00.hex; # navigation bar background
    toolbar_text = palette.base05.hex; # navigation bar text
    toolbar_field = palette.base01.hex; # navigation fields background -> URL bar
    toolbar_field_text = palette.base05.hex; # navigation bar fields text
    toolbar_field_border_focus = scheme.accent.hex; # focused input element
    popup = palette.base00.hex;
    popup_border = palette.base01.hex;
    popup_text = palette.base05.hex;
  };
}
