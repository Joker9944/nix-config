{
  lib,
  libSchemes,
  tinted-vscode,
  ...
}:
let
  # base00-base09, base0A-base0F, base10-base17 — the slot suffix is the index in hex.
  suffixes = lib.genList (index: lib.fixedWidthString 2 "0" (lib.toHexString index)) 24;
  slots = lib.map (suffix: "base${suffix}") suffixes;

  # A real palette hides departures wherever it repeats a color — Dracula's `base05` and
  # `base06` are the same hex, which would mask `terminal.ansiWhite`. Every slot here is
  # distinct, so the comparison reads slot assignments rather than colors. `accent` is
  # pinned to the slot upstream uses, isolating the table from our substitution for it.
  scheme = libSchemes.mkScheme {
    accent = "base0E";
    source = {
      name = "Sentinel";
      author = "nix-schemes tests";
      variant = "dark";
      palette = lib.listToAttrs (
        lib.map (suffix: {
          name = "base${suffix}";
          value = "#${suffix}${suffix}${suffix}";
        }) suffixes
      );
    };
  };

  ours = import ../../modules/home/vscode/theme scheme;

  upstream = builtins.fromJSON (
    builtins.replaceStrings
      (
        [
          "{{scheme-name}}"
          "{{scheme-variant}}"
        ]
        ++ lib.map (slot: "{{${slot}-hex}}") slots
      )
      (
        [
          scheme.meta.name
          scheme.meta.variant
        ]
        ++ lib.map (slot: scheme.palette.${slot}.hex) slots
      )
      (builtins.readFile "${tinted-vscode}/templates/base24.mustache")
  );

  theirColors = lib.mapAttrs (_: lib.toLower) upstream.colors;
  ourColors = lib.mapAttrs (_: lib.toLower) ours.colors;

  shared = lib.attrNames (lib.intersectAttrs theirColors ourColors);
  differing = lib.filter (key: theirColors.${key} != ourColors.${key}) shared;
  notCarried = lib.attrNames (removeAttrs theirColors (lib.attrNames ourColors));

  # Only the color is case-normalised; a scope is matched literally.
  lowerRule =
    rule:
    rule
    // lib.optionalAttrs (rule.settings ? foreground) {
      settings = rule.settings // {
        foreground = lib.toLower rule.settings.foreground;
      };
    };

  ruleName = rule: rule.name or (lib.head rule.scope);
  driftingRules = lib.map (pair: ruleName pair.fst) (
    lib.filter (pair: pair.fst != pair.snd) (
      lib.zipLists (lib.map lowerRule upstream.tokenColors) (lib.map lowerRule ours.tokenColors)
    )
  );
in
{
  # Every scope rule is upstream's, verbatim.
  testVscodeThemeTokenColorsMatchUpstream = {
    expr = driftingRules;
    expected = [ ];
  };

  testVscodeThemeTokenColorCountMatchesUpstream = {
    expr = lib.length ours.tokenColors == lib.length upstream.tokenColors;
    expected = true;
  };

  # Where the workbench table deliberately parts from upstream, sorted as `attrNames` gives
  # them. A key joining either list means upstream moved and the departure needs restating,
  # not that the theme is broken.
  #
  #   * the two shadows are #444444 upstream and the two borders base05, a near-white rule;
  #     all four are `base11`
  #   * upstream's ANSI block follows the out-of-date `Base24/base24` fork, so `colors.nix`
  #     reads the scheme's `ansi` view instead
  #   * `editorOverviewRuler.infoForeground` is base0C upstream and base0D on every other
  #     info key it sets; `status.info` is base0D
  testVscodeThemeColorsDepartFromUpstream = {
    expr = differing;
    expected = [
      "editorOverviewRuler.infoForeground"
      "panelInput.border"
      "scrollbar.shadow"
      "terminal.ansiBlack"
      "terminal.ansiBrightBlack"
      "terminal.ansiWhite"
      "terminal.ansiYellow"
      "terminal.border"
      "widget.shadow"
    ];
  };

  testVscodeThemeColorsNotCarriedFromUpstream = {
    expr = notCarried;
    expected = [
      # Renamed by VS Code; `colors.nix` sets `background1` / `activeBackground1`.
      "editorIndentGuide.activeBackground"
      "editorIndentGuide.background"
      # The singular `notification.*` family predates the notifications redesign and is
      # absent from the current theme-color reference; the `notifications.*` keys that
      # replaced it are all set.
      "notification.background"
      "notification.buttonBackground"
      "notification.buttonForeground"
      "notification.buttonHoverBackground"
      "notification.errorBackground"
      "notification.errorForeground"
      "notification.foreground"
      "notification.infoBackground"
      "notification.infoForeground"
      "notification.warningBackground"
      "notification.warningForeground"
    ];
  };

  # Guards the other direction: a key upstream drops leaves both lists above unchanged.
  testVscodeThemeColorsAgreeWithUpstream = {
    expr = lib.length shared - lib.length differing;
    expected = 202;
  };
}
