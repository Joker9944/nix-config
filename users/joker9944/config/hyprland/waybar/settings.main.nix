{
  osConfig,
  cfg,
  pkgs,
  ...
}:
let
  resourceMonitorInterval = 2;
  bin = {
    wpctl = "${osConfig.services.pipewire.wireplumber.package}/bin/wpctl";
    audiomenu = "${pkgs.audiomenu}/bin/audiomenu";
  };
in
{
  main = {
    modules-left = [ "hyprland/workspaces" ];
    modules-center = [ "clock" ];
    modules-right = [
      "group/cpu-group"
      "group/gpu-group"
      "group/memory-group"
      "group/disk-group"
      "group/network-group"
      "group/volume-group"
    ];

    clock = {
      interval = 1;
      tooltip = false;
      format = "{:%d. %b %H:%M}";
    };

    "custom/cpu-label" = {
      format = "CPU";
    };

    cpu = {
      interval = resourceMonitorInterval;
      format = "{usage:>3}%";
      max-length = 4;
    };

    "group/cpu-group" = {
      orientation = "horizontal";
      modules = [
        "custom/cpu-label"
        "cpu"
      ];
    };

    "custom/gpu-label" = {
      format = "GPU";
    };

    "custom/gpu" = {
      interval = resourceMonitorInterval;
      format = "{:>3}%";
      exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits";
    };

    "group/gpu-group" = {
      orientation = "horizontal";
      modules = [
        "custom/gpu-label"
        "custom/gpu"
      ];
    };

    "custom/memory-label" = {
      format = "Mem";
    };

    memory = {
      interval = resourceMonitorInterval;
      format = "{percentage:>3}%";
      max-length = 4;
    };

    "group/memory-group" = {
      orientation = "horizontal";
      modules = [
        "custom/memory-label"
        "memory"
      ];
    };

    "custom/disk-label" = {
      format = "Disk";
    };

    disk = {
      interval = resourceMonitorInterval;
      format = "{percentage_used:>3}%";
      max-length = 4;
    };

    "group/disk-group" = {
      orientation = "horizontal";
      modules = [
        "custom/disk-label"
        "disk"
      ];
    };

    "custom/network-label" = {
      format = "Net";
    };

    network = {
      interval = resourceMonitorInterval;
      format = "{bandwidthUpBits:>10}\n{bandwidthDownBits:>10}";
    };

    "group/network-group" = {
      orientation = "horizontal";
      modules = [
        "custom/network-label"
        "network"
      ];
    };

    "custom/volume-label" = {
      format = "Vol";
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
        format = "{volume:>3}%";
        format-muted = "  -%";
        max-length = 4;
        on-click = "${bin.audiomenu} --menu '${dmenuCommand}' select-sink";
        on-click-right = "${bin.wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

    "group/volume-group" = {
      orientation = "horizontal";
      modules = [
        "custom/volume-label"
        "wireplumber"
      ];
    };
  };
}
