{
  lib,
  config,
  ...
}:
let
  cfg = config.gnome-settings.peripherals;

  mkPointerSpeedOption =
    device:
    with lib;
    mkOption {
      type = types.numbers.between (-1) 1;
      default = 0;
      description = ''
        The ${device} pointer speed.
      '';
    };

  mkScrollDirectionOption =
    device: default:
    with lib;
    mkOption {
      type = types.enum [
        "traditional"
        "natural"
      ];
      default = default;
      description = ''
        The ${device} scroll direction.
      '';
    };

  mouseOptions =
    { ... }:
    {
      options = with lib; {
        pointerSpeed = mkPointerSpeedOption "mouse";

        mouseAcceleration = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to enable mouse acceleration.";
        };

        scrollDirection = mkScrollDirectionOption "mouse" "traditional";
      };
    };

  touchpadOptions =
    { ... }:
    {
      options = with lib; {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether to the touchpad.
          '';
        };

        disableTouchpadWhileTyping = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether to disable the touchpad while typing.
          '';
        };

        pointerSpeed = mkPointerSpeedOption "touchpad";

        secondaryClick = mkOption {
          type = types.enum [
            "two-finger-push"
            "corner-push"
          ];
          default = "two-finger-push";
          description = ''
            How to generate software-emulated buttons.
          '';
        };

        tapToClick = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether to enable double tapping as a click.
          '';
        };

        scrollMethod = mkOption {
          type = types.enum [
            "two-fingers"
            "edge"
          ];
          default = "two-fingers";
          description = ''
            The scroll method.
          '';
        };

        scrollDirection = mkScrollDirectionOption "touchpad" "natural";
      };
    };
in
{
  options.gnome-settings.peripherals = with lib; {
    enable = mkEnableOption "Whether to enable GNOME mouse & touchpad config.";

    primaryButton = mkOption {
      type = types.enum [
        "left"
        "right"
      ];
      default = "right";
      description = ''
        Order of physical buttons on mice and touchpad.
      '';
    };

    mouse = mkOption {
      type = types.submodule mouseOptions;
      default = {
        pointerSpeed = 0;
        mouseAcceleration = false;
        scrollDirection = "traditional";
      };
      example = lib.literalExpression ''
        {
          pointerSpeed = 1;
          mouseAcceleration = false;
          scrollDirection = "traditional";
        }
      '';
      description = ''
        Mouse behavior settings.
      '';
    };

    touchpad = mkOption {
      type = types.submodule touchpadOptions;
      default = {
        enable = true;
        disableTouchpadWhileTyping = true;
        pointerSpeed = 0;
        secondaryClick = "two-finger-push";
        tapToClick = true;
        scrollMethod = "two-fingers";
        scrollDirection = "natural";
      };
    };
  };

  config = {
    dconf.settings = {
      "org/gnome/desktop/peripherals/mouse" = {
        left-handed = cfg.primaryButton == "left";
        speed = cfg.mouse.pointerSpeed;
        accel-profile = if cfg.mouse.mouseAcceleration then "default" else "flat";
        natural-scroll = cfg.mouse.scrollDirection == "natural";
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        send-events = if cfg.touchpad.enable then "enabled" else "disabled";
        disable-while-typing = cfg.touchpad.disableTouchpadWhileTyping;
        speed = cfg.touchpad.pointerSpeed;
        click-method = if cfg.touchpad.secondaryClick == "two-finger-push" then "fingers" else "areas";
        tap-to-click = cfg.touchpad.tapToClick;
        two-finger-scrolling-enabled = cfg.touchpad.scrollMethod == "two-fingers";
        natural-scroll = cfg.touchpad.scrollDirection == "natural";
      };
    };
  };
}
