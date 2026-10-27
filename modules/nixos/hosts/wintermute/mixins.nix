_: {
  mixins = {
    boot.windowsSupport.enable = true;

    hardware = {
      battery.enable = true;
      intelCpu.enable = true;
    };

    networking.hosts.enable = true;

    services.openssh.enable = true;
  };
}
