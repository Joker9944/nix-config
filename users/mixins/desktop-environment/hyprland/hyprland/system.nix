{ mkHyprlandModule, ... }:
{
  lib,
  osConfig,
  ...
}:
mkHyprlandModule {
  home.sessionVariables.NIXOS_OZONE = 1;

  wayland.windowManager.hyprland.settings = {
    config = {
      # WORKAROUND Fix scaling for xwayland apps
      xwayland.force_zero_scaling = true;

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
    };

    window_rule = lib.mkBefore [
      {
        name = "fix-xwayland-drags";
        match = {
          class = "^$";
          title = "^$";
          xwayland = true;
          float = true;
          fullscreen = false;
          pin = false;
        };
        no_focus = true;
      }
      {
        name = "suppress-maximize-events";
        match.class = ".*";
        suppress_event = "maximize";
      }
    ];

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
  };
}
