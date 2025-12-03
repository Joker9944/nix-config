{
  lib,
  config,
  custom,
  ...
}:
let
  cfg = config.gnome-settings.peripherals;
in
{
  options.gnome-settings.peripherals =
    with lib;
    let
      mkPointerSpeedOption =
        device:
        mkOption {
          type = types.nullOr (types.numbers.between (-1) 1);
          default = null;
          description = ''
            The ${device} pointer speed.
          '';
        };

      mkScrollDirectionOption =
        device:
        mkOption {
          type = types.nullOr (
            types.enum [
              "traditional"
              "natural"
            ]
          );
          default = null;
          description = ''
            The ${device} scroll direction.
          '';
        };

      mouseOptions = types.submodule (_: {
        options = {
          pointerSpeed = mkPointerSpeedOption "mouse";

          mouseAcceleration = (mkEnableOption "mouse acceleration") // {
            type = types.nullOr types.bool;
            default = null;
          };

          scrollDirection = mkScrollDirectionOption "mouse";
        };
      });

      touchpadOptions = types.submodule (_: {
        options = {
          enable = (mkEnableOption "the touchpad") // {
            type = types.nullOr types.bool;
            default = null;
          };

          disableTouchpadWhileTyping = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to disable the touchpad while typing.
            '';
          };

          pointerSpeed = mkPointerSpeedOption "touchpad";

          secondaryClick = mkOption {
            type = types.nullOr (
              types.enum [
                "two-finger-push"
                "corner-push"
              ]
            );
            default = null;
            description = ''
              How to generate software-emulated buttons.
            '';
          };

          tapToClick = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to enable double tapping as a click.
            '';
          };

          scrollMethod = mkOption {
            type = types.nullOr (
              types.enum [
                "two-fingers"
                "edge"
              ]
            );
            default = null;
            description = ''
              The scroll method.
            '';
          };

          scrollDirection = mkScrollDirectionOption "touchpad";
        };
      });
    in
    {
      enable = mkEnableOption "GNOME mouse and touchpad config";

      primaryButton = mkOption {
        type = types.nullOr (
          types.enum [
            "left"
            "right"
          ]
        );
        default = null;
        description = ''
          Order of physical buttons on mice and touchpad.
        '';
      };

      mouse = mkOption {
        type = types.nullOr mouseOptions;
        default = { };
        description = ''
          Mouse behavior settings.
        '';
      };

      touchpad = mkOption {
        type = types.nullOr touchpadOptions;
        default = { };
        description = ''
          Touchpad behavior settings.
        '';
      };
    };

  config = {
    dconf.settings = {
      "org/gnome/desktop/peripherals/mouse" = {
        left-handed = lib.mkIf (cfg.primaryButton != null) (cfg.primaryButton == "left");
        speed = custom.lib.nonNull cfg.mouse.pointerSpeed;
        accel-profile = lib.mkIf (cfg.mouse.mouseAcceleration != null) (
          if cfg.mouse.mouseAcceleration then "default" else "flat"
        );
        natural-scroll = lib.mkIf (cfg.mouse.scrollDirection != null) (
          cfg.mouse.scrollDirection == "natural"
        );
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        send-events = lib.mkIf (cfg.touchpad.enable != null) (
          if cfg.touchpad.enable then "enabled" else "disabled"
        );
        disable-while-typing = custom.lib.nonNull cfg.touchpad.disableTouchpadWhileTyping;
        speed = custom.lib.nonNull cfg.touchpad.pointerSpeed;
        click-method = lib.mkIf (cfg.touchpad.secondaryClick != null) (
          if cfg.touchpad.secondaryClick == "two-finger-push" then "fingers" else "areas"
        );
        tap-to-click = custom.lib.nonNull cfg.touchpad.tapToClick;
        two-finger-scrolling-enabled = lib.mkIf (cfg.touchpad.scrollMethod != null) (
          cfg.touchpad.scrollMethod == "two-fingers"
        );
        natural-scroll = lib.mkIf (cfg.touchpad.scrollDirection != null) (
          cfg.touchpad.scrollDirection == "natural"
        );
      };
    };
  };
}
