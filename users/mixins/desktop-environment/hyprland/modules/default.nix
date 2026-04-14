{ mkDefaultHyprlandModule, ... }:
mkDefaultHyprlandModule { dir = ./.; } {
  mixins.desktopEnvironment.hyprland.binds.mods = {
    main = "SUPER";
    workspace = "SUPER SHIFT";
    utility = "SUPER CTRL";
    app = "SUPER ALT";
  };
}
