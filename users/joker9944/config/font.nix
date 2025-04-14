{pkgs, ...}: {
  home.packages = with pkgs; [jetbrains-mono];

  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      monospace = ["JetBrains Mono"];
    };
  };
}
