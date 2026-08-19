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

      settings = {
        # general
        telemetry.system_info = false;
        global_shortcuts.toggle = ""; # bind handled in hyprland
        providers.applications.preferences.launchPrefix = cfg.mkAppCommand { };

        # additional theming
        launcher_window.opacity = cfg.style.opacity.active;
        font.normal =
          let
            interfaceFont = config.custom.theme.fonts.interface;
          in
          {
            family = interfaceFont.name;
            inherit (interfaceFont) size;
          };

        # preferences
        providers = {
          clipboard.entrypoints.history.alias = "clip";

          core.entrypoints = {
            search-emojis.alias = "emoji";
            about.enabled = false;
            documentation.enabled = false;
            sponsor.enabled = false;
          };

          files.entrypoints.search.alias = "file";

          power.entrypoints = {
            power-off.alias = "poweroff";
            reboot.alias = "reboot";
          };

          system.entrypoints = {
            run.alias = "run";
            toggle-mute.enabled = false;
            volume-0.enabled = false;
            volume-25.enabled = false;
            volume-50.enabled = false;
            volume-75.enabled = false;
            volume-100.enabled = false;
            volume-down.enabled = false;
            volume-up.enabled = false;
          };
        };
      };
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
