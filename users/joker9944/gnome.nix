{ lib, config, pkgs, ...}:

with lib; let
  mkAutoMoveWindowsApplicationList = attrs: attrValues ( mapAttrs ( app: index: app + ":" + toString index ) attrs );
in {
  dconf.settings = with lib.gvariant; {
    # Theming
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";

    # Keybindings
    "org/gnome/desktop/wm/keybindings" = {
      move-to-monitor-up = mkEmptyArray type.string;
      move-to-monitor-down = mkEmptyArray type.string;
      move-to-workspace-left = [ "<Shift><Super>Up" ];
      move-to-workspace-right = [ "<Shift><Super>Down" ];
      switch-to-workspace-left = [ "<Control><Super>Up" ];
      switch-to-workspace-right = [ "<Control><Super>Down" ];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = [ "<Super>Escape" ];
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

    # Extensions
    "org/gnome/shell/extensions/dash-to-dock" = {
      always-center-icons = true;
      apply-custom-theme = true;
      dock-position = "LEFT";
      show-trash = false;
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
  };
}
