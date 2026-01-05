# https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/manifest.json/theme#colors
cfg:
let
  inherit (cfg.scheme) palette;
in
builtins.toJSON {
  manifest_version = 2;
  version = "1.0.0";
  inherit (cfg.scheme) name author;
  browser_specific_settings.gecko.id = cfg.addonId;
  theme.colors = {
    frame = palette.base00.hex; # active frame background
    toolbar = palette.base02.hex; # navigation bar background
    toolbar_text = palette.base05.hex; # navigation bar text
    toolbar_field = palette.base01.hex; # navigation fields background -> URL bar
    toolbar_field_text = palette.base05.hex; # navigation bar fields text
    #tab_text = ""; # active tab text
    tab_background_text = palette.base05.hex; # general tab text
    popup = palette.base00.hex;
    popup_boarder = palette.base01.hex;
    popup_text = palette.base05.hex;
  };
}
