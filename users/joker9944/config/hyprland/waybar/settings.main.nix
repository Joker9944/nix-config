{cfg, ...}: {
  main = let
    resourceMonitorInterval = 2;
  in {
    modules-left = ["hyprland/workspaces"];
    modules-center = ["clock"];
    modules-right = [
      "group/cpu-group"
      "group/gpu-group"
      "group/memory-group"
      "group/disk-group"
      "group/network-group"
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
      modules = ["custom/cpu-label" "cpu"];
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
      modules = ["custom/gpu-label" "custom/gpu"];
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
      modules = ["custom/memory-label" "memory"];
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
      modules = ["custom/disk-label" "disk"];
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
      modules = ["custom/network-label" "network"];
    };
  };
}
