{ mkMixinModule, ... }:
mkMixinModule "jetbrains-idea" {
  programs = {
    jetbrains.idea = {
      enable = true;

      vmoptions = [
        "-Xmx4096m"
        { "-Dawt.toolkit.name" = "WLToolkit"; }
      ];
    };

    openjdk.versions = [ 8 ];
  };

  wayland.windowManager.hyprland.settings.window_rule = [
    {
      name = "jetbrains";
      match = {
        class = "^jetbrains-.+$";
        initial_title = "^$";
      };
      no_initial_focus = true;
    }
  ];
}
