_: {
  mixins = {
    boot.windowsSupport.enable = true;

    networking.hosts.enable = true;

    services.openssh.enable = true;
  };
}
