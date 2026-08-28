{ libUtil, ... }:
{
  testSlugifyAlreadyASlug = {
    expr = libUtil.strings.slugify "gruvbox-dark-hard";
    expected = "gruvbox-dark-hard";
  };

  testSlugifySpaces = {
    expr = libUtil.strings.slugify "Cerulean Signal Light";
    expected = "cerulean-signal-light";
  };

  testSlugifyUppercase = {
    expr = libUtil.strings.slugify "ORCHIDLIFT LUME";
    expected = "orchidlift-lume";
  };

  # A run of separators collapses to one dash rather than repeating
  testSlugifyCollapsesRuns = {
    expr = libUtil.strings.slugify "Gruvbox dark, hard";
    expected = "gruvbox-dark-hard";
  };

  testSlugifyCollapsesBrackets = {
    expr = libUtil.strings.slugify "Black Metal (Bathory)";
    expected = "black-metal-bathory";
  };

  testSlugifyTrimsEnds = {
    expr = libUtil.strings.slugify "  Spaced  Out!  ";
    expected = "spaced-out";
  };

  testSlugifyAcute = {
    expr = libUtil.strings.slugify "Rosé Pine Dawn";
    expected = "rose-pine-dawn";
  };

  testSlugifyAcuteO = {
    expr = libUtil.strings.slugify "Pastelón de Amarillos";
    expected = "pastelon-de-amarillos";
  };

  testSlugifyUmlaut = {
    expr = libUtil.strings.slugify "Münchner Nächte";
    expected = "munchner-nachte";
  };

  testSlugifyNordic = {
    expr = libUtil.strings.slugify "Århus Blå Øre";
    expected = "arhus-bla-ore";
  };

  # Latin Extended-A, including the stroked letters NFKD leaves alone
  testSlugifyLatinExtendedA = {
    expr = libUtil.strings.slugify "Łódź Žluťoučký";
    expected = "lodz-zlutoucky";
  };

  # A letter with no single-character ASCII base is spelled out
  testSlugifyEszett = {
    expr = libUtil.strings.slugify "Straße";
    expected = "strasse";
  };

  testSlugifyLigature = {
    expr = libUtil.strings.slugify "Æther Œuvre";
    expected = "aether-oeuvre";
  };

  # Uppercase transliterates before the lowercasing pass, which is ASCII-only
  testSlugifyUppercaseDiacritic = {
    expr = libUtil.strings.slugify "ÉCLAIR";
    expected = "eclair";
  };

  testSlugifyDigitsSurvive = {
    expr = libUtil.strings.slugify "Base16 Theme 2";
    expected = "base16-theme-2";
  };

  # Scripts with no ASCII equivalent are not romanised; they separate like punctuation
  testSlugifyDropsNonLatin = {
    expr = libUtil.strings.slugify "Dark Θέμα Mode";
    expected = "dark-mode";
  };

  testSlugifyEmptyResultThrows = {
    expr = (builtins.tryEval (libUtil.strings.slugify "Θέμα")).success;
    expected = false;
  };

  testSlugifyEmptyInputThrows = {
    expr = (builtins.tryEval (libUtil.strings.slugify "")).success;
    expected = false;
  };
}
