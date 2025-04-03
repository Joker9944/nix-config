{pkgs, ...}: {
  # WORKAROUND home-manager does not supply a way to set autostart apps
  # https://github.com/nix-community/home-manager/issues/3447
  # TODO upgrade once stable
  # https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.autostart.entries
  xdg.autoStart.desktopItems = with pkgs; {
    steam = makeDesktopItem {
      name = "steam";
      desktopName = "Steam";
      exec = "steam %U";
    };
  };
}
