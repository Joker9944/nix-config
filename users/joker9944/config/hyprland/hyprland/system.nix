{
  lib,
  config,
  osConfig,
  utility,
  ...
}: let
  cfg = config.desktopEnvironment.hyprland;
in
  utility.custom.mkHyprlandModule config {
    wayland.windowManager.hyprland.settings = {
      monitor = lib.mkDefault [",preferred,auto,auto"];

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
      input = let
        osConfigXkb = osConfig.services.xserver.xkb;
      in {
        kb_layout = osConfigXkb.layout;
        kb_variant = osConfigXkb.variant;
        kb_model = osConfigXkb.model;
        kb_options = osConfigXkb.options;

        follow_mouse = 1;

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

        # TODO get a feel on laptop
        touchpad = {
          natural_scroll = false;
        };
      };

      # https://wiki.hyprland.org/Configuring/Variables/#gestures
      # TODO get a feel on laptop
      gestures = {
        workspace_swipe = false;
      };

      # Windows and workspaces
      windowrule = [
        # Ignore maximize requests from apps. You'll probably like this.
        # Match everything besides steam games
        "suppressevent maximize, class:negative:${cfg.steam.appRegex}"
        # Fix some dragging issues with XWayland
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];
    };
  }
