{
  lib,
  config,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = config.windowManager.hyprland.custom;
  resourceMonitorInterval = 2;
  bin = {
    wpctl = lib.getExe' osConfig.services.pipewire.wireplumber.package "wpctl";
    audiomenu = lib.getExe pkgs.audiomenu;
  };
in
{
  main = {
    modules-left = [ "hyprland/workspaces" ];
    modules-center = [ "clock" ];

    modules-right = [
      "cpu"
    ]
    ++ (lib.optional cfg.waybar.gpu "custom/gpu")
    ++ [
      "memory"
      "disk"
      "group/network-group"
      "wireplumber"
    ]
    ++ (lib.optional cfg.waybar.battery "upower#bat")
    ++ (lib.optional cfg.waybar.stylus "upower#stylus");

    "hyprland/workspaces" = {
      show-special = true;

      format = "{icon}";

      format-icons = {
        telegram = "<span foreground=\"#27A7E7\"></span>";
        discord = "<span color=\"#7289DA\"></span>";
        spotify = "<span color=\"#1ED760\"></span>";
      };
    };

    clock = {
      interval = 1;
      tooltip = false;
      format = "{:%d. %b %H:%M}";
    };

    cpu = {
      interval = resourceMonitorInterval;
      format = "<b>CPU</b> <tt>{usage:>3}%</tt>";
    };

    "custom/gpu" = {
      interval = resourceMonitorInterval;
      format = "<b>GPU</b> <tt>{:>3}%</tt>";
      exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits";
    };

    memory = {
      interval = resourceMonitorInterval;
      format = "<b>Mem</b> <tt>{percentage:>3}%</tt>";
    };

    disk = {
      interval = resourceMonitorInterval;
      format = "<b>Disk</b> <tt>{percentage_used:>3}%</tt>";
    };

    "custom/network-label" = {
      format = "<b>Net</b> ";
    };

    network = {
      interval = resourceMonitorInterval;
      format = "<span face=\"monospace\" size=\"70%\">{bandwidthUpBits:>10}\n{bandwidthDownBits:>10}</span>";
    };

    "group/network-group" = {
      orientation = "horizontal";
      modules = [
        "custom/network-label"
        "network"
      ];
    };

    wireplumber =
      let
        dmenuCommand = cfg.launcher.mkDmenuCommand {
          location = "top_right";
          search = false;
          width = 600;
          height = 200;
        };
      in
      {
        format = "<b>Vol</b> <tt>{volume:>3}%</tt>";
        format-muted = "<b>Vol</> <tt>  -%</tt>";
        max-length = 8;
        on-click = "${bin.audiomenu} --menu '${dmenuCommand}' select-sink";
        on-click-right = "${bin.wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

    "upower#bat" = {
      native-path = "BAT0";
      format = "<b>Chrg</b> <tt>{percentage:>3}%</tt>"; # cSpell:words chrg
    };

    "upower#stylus" = {
      native-path = "wacom_battery_0";
      format = "<b>Pen</b> <tt>{percentage:>3}%</tt>";
    };
  };
}
