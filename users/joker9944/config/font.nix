{pkgs, ...}: {
  home.packages = with pkgs; [
    jetbrains-mono
    lato
    roboto
    noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      monospace = ["JetBrains Mono"];
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
