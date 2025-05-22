{pkgs, ...}: {
  home.packages = with pkgs; [
    jetbrains-mono
    lato
    roboto
  ];

  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      monospace = ["JetBrains Mono"];
      sansSerif = [
        "Lato"
        "Roboto"
      ];
    };
  };
}
