{ mkHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-unstable,
  custom,
  ...
}:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
in
mkHyprlandModule {
  options.mixins.desktopEnvironment.hyprland.launcher.vicinae =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "vicinae hyprland launcher";
    };

  config = lib.mkIf cfg.launcher.vicinae.enable {
    programs.vicinae = {
      enable = true;
      package = pkgs-unstable.vicinae;

      systemd = {
        enable = true;
        target = config.wayland.systemd.target;
      };

      settings.launcher_window.opacity = cfg.style.opacity.active;
    };

    schemes.vicinae.enable = true;

    mixins.desktopEnvironment.hyprland.launcher = {
      toggleCommand = "vicinae toggle";

      mkDmenuCommand =
        {
          width ? null,
          height ? null,
          ...
        }:
        custom.libUtil.strings.mkCommand [
          "vicinae"
          "dmenu"
          (lib.optional (width != null) [
            "--width"
            (toString width)
          ])
          (lib.optional (height != null) [
            "--height"
            (toString height)
          ])
        ];
    };

    wayland.windowManager.hyprland.settings.layer_rule = [
      {
        name = "vicinae-blur";
        blur = true;
        no_anim = true;
        ignore_alpha = 0;
        match.namespace = "vicinae";
      }
    ];
  };
}
