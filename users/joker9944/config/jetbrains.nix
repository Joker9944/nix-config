{pkgs-unstable, ...}: {
  home = {
    packages = with pkgs-unstable; [
      jetbrains.idea-ultimate
      jetbrains.pycharm-professional
      jetbrains.webstorm
      nodejs
    ];
  };

  programs.openjdk.versions = [8 11 17 21];
}
