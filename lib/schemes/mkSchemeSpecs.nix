/**
  Resolve every hyprland style's color scheme into a serializable spec, keyed by
  theme name.

  The theme list comes from the `style.theme` option's own enum, so a new style
  appears here as soon as it is added to `users/mixins/desktop-environment/hyprland/styling/`.
  Each theme is resolved by re-evaluating the home configuration with that theme
  forced, which runs the style's full transformer chain — the spec is what the
  system actually themes with, not what the upstream scheme file says.

  # Type

  ```
  mkSchemeSpecs :: { username :: string, hostname :: string } -> attrs
  ```

  # Example

  ```nix
  mkSchemeSpecs { username = "joker9944"; hostname = "HAL9000"; }
  => { dracula = { name = "Dracula"; palette = { … }; ansi = { … }; }; uwunicorn = { … }; }
  ```
*/
{
  flake,
  lib,
  inputs,
  ...
}:
{
  username,
  hostname,
}:
let
  inherit (inputs.nix-schemes.lib) libSchemes;

  homeConfiguration = flake.homeConfigurations."${username}@${hostname}";

  themeOption = homeConfiguration.options.mixins.desktopEnvironment.hyprland.style.theme;
  themes = themeOption.type.functor.payload.values;

  specForTheme =
    theme:
    lib.pipe theme [
      (theme: {
        modules = [ { mixins.desktopEnvironment.hyprland.style.theme = theme; } ];
      })
      homeConfiguration.extendModules
      (configuration: configuration.config.schemes.scheme)
      libSchemes.toSpec
    ];
in
lib.genAttrs themes specForTheme
