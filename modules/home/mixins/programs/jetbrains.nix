{ mkMixinModule, ... }:
{ pkgs, ... }:
mkMixinModule "jetbrains" {
  home.packages = with pkgs; [ nodejs ];

  programs = {
    jetbrains = {
      idea = {
        enable = true;

        vmoptions = [
          "-Xmx4096m"
          { "-Dawt.toolkit.name" = "WLToolkit"; }
        ];
      };

      webstorm = {
        enable = true;

        vmoptions = [
          "-Xmx4096m"
          { "-Dawt.toolkit.name" = "WLToolkit"; }
        ];
      };

      pycharm.enable = true;

      goland.enable = true;
    };

    openjdk.versions = [
      8
      11
      17
      21
      25
    ];
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
