{
  config,
  pkgs,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  gtk = {
    enable = true;

    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };

    cursorTheme = {
      name = "Dracula-cursors";
      package = pkgs.dracula-theme;
      size = 16;
    };

    iconTheme = {
      name = "Dracula";
      package = pkgs.dracula-icon-theme;
    };
  };

  gnome-settings.appearance = {
    enable = true;

    style = "prefer-dark";
    accentColor = "purple";
  };

  gnome-tweaks.fonts = {
    enable = true;

    interfaceText = {
      name = "Inter";
      package = pkgs.inter;
      size = 10;
    };

    documentText = {
      name = "Lato";
      package = pkgs.lato;
      size = 12;
    };

    monospaceText = {
      name = "JetBrains Mono";
      package = pkgs.jetbrains-mono;
      size = 10;
    };
  };
}
