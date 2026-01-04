{
  lib,
  config,
  osConfig,
  custom,
  ...
}:
let
  cfg = config.windowManager.hyprland.custom.system;
in
custom.lib.mkHyprlandModule config {
  options.windowManager.hyprland.custom.system = with lib; {
    environment = mkOption {
      type = types.attrsOf (
        types.oneOf [
          types.str
          types.int
          types.bool
        ]
      );
      default = { };
      example = literalExpression ''
        {
          GDK_SCALE = 2;
          NIXOS_OZONE_WL = 1;
        }
      '';
      description = ''
        Environment variables templated into Hyprland `env`.
      '';
    };

    allowMaximized = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "steam_app_.+" ];
      description = ''
        RegEx expressions of windows which should be allowed to maximize.
      '';
    };
  };

  config = {

    windowManager.hyprland.custom.system.environment.NIXOS_OZONE = 1;

    wayland.windowManager.hyprland.settings = {
      monitor = lib.mkDefault [ ",preferred,auto,auto" ];

      env = lib.attrsets.mapAttrsToList (name: value: "${name}, ${toString value}") cfg.environment;

      # WORKAROUND Fix scaling for xwayland apps
      xwayland = {
        force_zero_scaling = true;
      };

      # Permissions
      # TODO set this up

      # See https://wiki.hyprland.org/Configuring/Permissions/
      # Please note permission changes here require a Hyprland restart and are not applied on-the-fly
      # for security reasons

      # ecosystem {
      #   enforce_permissions = 1
      # }

      # permission = /usr/(bin|local/bin)/grim, screencopy, allow
      # permission = /usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland, screencopy, allow
      # permission = /usr/(bin|local/bin)/hyprpm, plugin, allow

      # https://wiki.hyprland.org/Configuring/Variables/#input
      input =
        let
          osConfigXkb = osConfig.services.xserver.xkb;
        in
        {
          kb_layout = osConfigXkb.layout;
          kb_variant = osConfigXkb.variant;
          kb_model = osConfigXkb.model;
          kb_options = osConfigXkb.options;

          follow_mouse = 1;

          # TODO get a feel on laptop
          touchpad = {
            natural_scroll = false;
          };
        };

      # Windows and workspaces
      windowrule =
        let
          maximizeRegex = "(${lib.concatStringsSep "|" cfg.allowMaximized})";
        in
        [
          # Fix some dragging issues with XWayland
          "match:class ^$, match:title ^$, match:xwayland true, match:float true, match:fullscreen false, match:pin false, no_focus on"
        ]
        # Ignore maximize requests from apps. You'll probably like this.
        ++ lib.optional (
          lib.length cfg.allowMaximized > 0
        ) "match:class negative:${maximizeRegex}, suppress_event maximize";
    };
  };
}
