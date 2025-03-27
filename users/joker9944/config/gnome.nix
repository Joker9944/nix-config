{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.hm.gvariant; let
  mkAutoMoveWindowsApplicationList = attrs: attrValues (mapAttrs (app: index: app + ":" + toString index) attrs);
in {
  dconf.settings = {
    # Theming
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      accent-color = "purple";
    };

    # Keybindings
    "org/gnome/desktop/wm/keybindings" = {
      move-to-monitor-up = mkEmptyArray type.string;
      move-to-monitor-down = mkEmptyArray type.string;
      move-to-workspace-left = ["<Shift><Super>Up"];
      move-to-workspace-right = ["<Shift><Super>Down"];
      switch-to-workspace-left = ["<Control><Super>Up"];
      switch-to-workspace-right = ["<Control><Super>Down"];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = ["<Super>Escape"];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };
    "org/gnome/settings-daemon/plugins/custom-keybindings/custom0" = {
      name = "Console";
      binding = "<Super>t";
      command = "kgx";
    };
    "org/gnome/settings-daemon/plugins/custom-keybindings/custom1" = {
      name = "btop++";
      binding = "<Shift><Control>Escape";
      command = "kgx -- btop";
    };
    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts = mkEmptyArray type.string;
    };

    # Weather
    "org/gnome/GWeather4" = {
      temperature-unit = "centigrade";
    };
    "org/gnome/shell/weather" = {
      automatic-location = true;
    };

    # Extensions
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "clipboard-history@alexsaveau.dev"
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "dash-to-panel@jderose9.github.com"
        "tophat@fflewddur.github.io"
        "dash-to-dock@micxgx.gmail.com"
        "places-menu@gnome-shell-extensions.gcampax.github.com"
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
      ];
    };
    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "LEFT"; # Position on screen
      dock-fixed = true; # ! Intelligent autohide
      extend-height = true; # Panel mode
      always-center-icons = true;
      dash-max-icon-size = 32; # Icon size limit
      show-trash = false;
      apply-custom-theme = true; # Use built-in theme
    };
    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = mkAutoMoveWindowsApplicationList {
        "steam.desktop" = 1;
        "discord.desktop" = 2;
        "org.telegram.desktop.desktop" = 2;
        "code.desktop" = 3;
        "spotify.desktop" = 4;
      };
    };
    "org/gnome/shell/extensions/tophat" = {
      fs-display = "numeric";
      mem-display = "numeric";
      network-usage-unit = "bits";
    };
  };
}
