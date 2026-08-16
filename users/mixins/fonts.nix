{ mkMixinModule, ... }:
{ pkgs, ... }:
mkMixinModule "fonts" {
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    lato
    roboto
    noto-fonts-color-emoji
    jetbrains-mono
  ];

  fonts.fontconfig = {
    enable = true;

    # `monospace` and `emoji` are bound by the theme. Setting them here too would concatenate
    # into one murky preference list rather than conflict — `defaultFonts.*` is a `listOf str`.
    defaultFonts.sansSerif = [
      "Lato"
      "Roboto"
    ];
  };
}
