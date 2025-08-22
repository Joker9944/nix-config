{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    lato
    roboto
    noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      monospace = [ "JetBrains Mono Nerd Font" ];
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
