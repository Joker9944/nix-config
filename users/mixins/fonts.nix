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

    defaultFonts = {
      monospace = [
        "JetBrainsMono Nerd Font Mono"
        "JetBrains Mono"
      ];
      sansSerif = [
        "Lato"
        "Roboto"
      ];
      emoji = [
        "Noto Color Emoji"
      ];
    };
  };
}
