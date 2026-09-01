{ lib, libSchemes, ... }:
let
  themeOf =
    system: slug:
    import ../../modules/home/vscode/theme (
      libSchemes.mkScheme { source = libSchemes.generateScheme system slug; }
    );

  dark = themeOf "base24" "dracula";
  upcast = themeOf "base16" "gruvbox-dark-hard";
  light = themeOf "base16" "one-light";

  malformed =
    theme:
    lib.attrNames (
      lib.filterAttrs (
        _: value: !lib.isString value || builtins.match "#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?" value == null
      ) theme.colors
    );

  scopeless = theme: lib.filter (rule: !(rule ? scope && rule ? settings)) theme.tokenColors;

  malformedRules =
    theme:
    lib.filter (
      rule:
      rule.settings ? foreground
      && (
        !lib.isString rule.settings.foreground
        || builtins.match "#[0-9a-fA-F]{6}" rule.settings.foreground == null
      )
    ) theme.tokenColors;
in
{
  # A slot reached without the `hex` helper serialises as a JSON object, which VS Code
  # drops without complaint.
  testVscodeThemeColorsAreHexStrings = {
    expr = malformed dark;
    expected = [ ];
  };

  testVscodeThemeUpcastColorsAreHexStrings = {
    expr = malformed upcast;
    expected = [ ];
  };

  testVscodeThemeTokenRulesAreWellFormed = {
    expr = scopeless dark;
    expected = [ ];
  };

  testVscodeThemeTokenColorsAreHexStrings = {
    expr = malformedRules dark;
    expected = [ ];
  };

  # A base16 source is upcast on construction, so it reaches every slot a base24 one does.
  testVscodeThemeUpcastCoversSameKeys = {
    expr = lib.attrNames upcast.colors == lib.attrNames dark.colors;
    expected = true;
  };

  testVscodeThemeTypeFollowsVariant = {
    expr = [
      dark.type
      light.type
    ];
    expected = [
      "dark"
      "light"
    ];
  };

  testVscodeThemeNameFollowsScheme = {
    expr = dark.name;
    expected = "Dracula";
  };

  testVscodeThemeAnsiFollowsSchemeView = {
    expr = dark.colors."terminal.ansiBrightGreen";
    expected = "#${
      (libSchemes.mkScheme { source = libSchemes.generateScheme "base24" "dracula"; }).ansi."A".hex
    }";
  };
}
