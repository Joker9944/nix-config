{
  scheme,
  colors,
  addonId,
}:
builtins.toJSON {
  manifest_version = 2;
  version = "1.0.0";
  inherit (scheme.meta) name author;
  browser_specific_settings.gecko.id = addonId;
  theme.colors = builtins.mapAttrs (_: color: "rgb(${color.rgb})") colors;
}
