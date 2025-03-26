{ pkgs, ...}:

{
  # WORKAROUND home-manager does not supply a way to set autostart apps
  # https://github.com/nix-community/home-manager/issues/3447
  xdg.autoStart.desktopItems = with pkgs; {
    steam = makeDesktopItem {
      name = "steam";
      desktopName = "Steam";
      exec = "steam %U";
    };
  };
}
