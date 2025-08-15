{
  lib,
  config,
  osConfig,
  pkgs-hyprland,
  ...
} @ moduleArgs:
with lib; let
  cfg = config.desktopEnvironment.hyprland;
in {
  imports = [./hyprland];

  options.desktopEnvironment.hyprland = with lib; {
    enable = mkEnableOption "Hyprland config";

    monitor = mkOption {
      type = types.listOf types.str;
      default = [",preferred,auto,auto"];
      description = ''
        Hyprland monitor setup

        https://wiki.hypr.land/Configuring/Monitors/
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs-hyprland; [
      wl-clipboard # Wayland clipboard utilities
      playerctl # control media applications
    ];

    services = {
      dunst = {
        # notification daemon
        enable = true;
        package = pkgs-hyprland.dunst;
      };

      cliphist = {
        # clipboard history daemon
        enable = true;
        package = pkgs-hyprland.cliphist;
      };

      hyprpaper = {
        # wallpaper management daemon
        enable = true;
        package = pkgs-hyprland.hyprpaper;
      };

      hypridle = {
        # idle management daemon
        enable = true;
        package = pkgs-hyprland.hypridle;
      };

      udiskie = {
        # mount daemon
        enable = true;
        # TODO Not supported in release-25.05 reenable when updating to release-25.11
        #package = pkgs-hyprland.udiskie;
      };
    };

    programs = {
      waybar = {
        # status bar
        enable = true;
        package = pkgs-hyprland.waybar;

        systemd.enable = true;
      };

      hyprlock = {
        # lock screen
        enable = true;
        package = pkgs-hyprland.hyprlock;
      };

      wofi = {
        # launcher
        enable = true;
        package = pkgs-hyprland.wofi;
      };

      yazi = {
        # file explorer
        enable = true;
        package = pkgs-hyprland.yazi;
      };
    };

    # TODO config
    # - waybar
    # - yazi
    # - wofi
    # - hyprlock
    # - hyprpaper
    # - hypridle

    # TODO Setup
    # - maybe replace hyprlock with a login and lock screen
    # - Investigate hyprpolkitagent
    # - There are a lot of styling utils take a look once theming
    # - Enable ly once saying goodbye to GNOME
    # - hyprshot

    wayland = {
      systemd.target = lib.mkIf config.wayland.windowManager.hyprland.systemd.enable "hyprland-session.target";

      windowManager.hyprland = {
        enable = true;

        # Hyprland installed trough NixOS
        package = null;
        portalPackage = null;

        settings = {
          monitor = cfg.monitor;

          "$terminal" = "kitty";
          "$fileManager" = "kitty --app-id=yazi yazi";
          "$menu" = "wofi --show drun";
          "$clipboard" = "cliphist list | wofi --dmenu | cliphist decode | wl-copy";
          "$browser" = "firefox";
          "$editor" = "codium";
          "$systemMonitor" = "btop";
          "$screenLock" = "hyprlock";

          # autostart
          exec-once = [
            # system
            "wl-paste --type text --watch cliphist store"
          ];

          # Environment variables
          # https://wiki.hyprland.org/Configuring/Environment-variables/
          env = lib.attrsets.mapAttrsToList (name: value: name + "," + value) {
            "XCURSOR_SIZE" = "24";
            "HYPRCURSOR_SIZE" = "24";
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

          # Input

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
            # Match everything besisdes steam games
            "suppressevent maximize, class:^(?!(steam_app_)).*$"
            # Fix some dragging issues with XWayland
            "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
          ];
        };
      };
    };
  };
}
