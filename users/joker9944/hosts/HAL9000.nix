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

  home.packages = with pkgs; [
    prismlauncher
    lutris
  ];

  programs.btop.package = pkgs.btop-cuda;

  programs._1password.gitSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9R2V8FqyXifBoVO3OndfpRrqxdwK1H/3qlm645l7rg";

  gnome-settings.peripherals.touchpad.enable = false;
}
