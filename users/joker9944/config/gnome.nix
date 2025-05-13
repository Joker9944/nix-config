{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.common.desktopEnvironment.gnome;
  mkAutoMoveWindowsApplicationList = attrs: attrValues (mapAttrs (app: index: app + ":" + toString index) attrs);
in {
  options.common.desktopEnvironment.gnome = with lib; {
    enable = mkEnableOption "Whether to enable GNOME desktop environment config.";
  };

  config = lib.mkIf cfg.enable {
    # Extensions
    home.packages = with pkgs; [
      gnomeExtensions.tophat
      gnomeExtensions.clipboard-history
      gnomeExtensions.auto-move-windows
      dconf-editor
      gparted
    ];

    # Theming
    gtk = {
      enable = true;
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1; # Legacy theming
    };

    dconf.settings = with lib.hm.gvariant; {
      # Extensions
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          # Custom extensions
          "tophat@fflewddur.github.io"
          "clipboard-history@alexsaveau.dev"
          "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
          # Built-in extensions
          "places-menu@gnome-shell-extensions.gcampax.github.com"
          "apps-menu@gnome-shell-extensions.gcampax.github.com"
        ];
      };

      # Theming
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        accent-color = "purple";
      };
      "org/gnome/shell/extensions/tophat" = {
        # Memory
        mem-display = "numeric";
        # Disk
        fs-display = "numeric";
        mount-to-monitor = "/";
        fs-hide-in-menu = "/boot";
        # Network
        network-usage-unit = "bits";
      };

      # Behaviour
      "org/gnome/shell/app-switcher" = {
        current-workspace-only = true;
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

      # Keybindings
      "org/gnome/desktop/wm/keybindings" = {
        move-to-monitor-up = mkEmptyArray type.string;
        move-to-monitor-down = mkEmptyArray type.string;
        move-to-monitor-left = mkEmptyArray type.string;
        move-to-monitor-right = mkEmptyArray type.string;
        move-to-workspace-left = ["<Shift><Super>Left"];
        move-to-workspace-right = ["<Shift><Super>Right"];
        switch-to-workspace-left = ["<Control><Super>Left"];
        switch-to-workspace-right = ["<Control><Super>Right"];
        maximize = ["<Super>Page_Up"];
        unmaximize = ["<Super>Page_Down"];
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        screensaver = ["<Super>Escape" "<Super>L"];
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "Launch Console";
        binding = "<Super>t";
        command = "kgx";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "Launch btop++";
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
    };
  };
}
