_: {
  mixins = {
    boot.windowsSupport.enable = true;

    hardware = {
      nvidia.enable = true;
      nvidiaCuda.enable = true;
    };

    networking.hosts.enable = true;

    programs = {
      ffmpeg.enable = true;
      steam = {
        enable = true;
        resolution = "2560x1440";
      };
    };

    virtualisation.docker.enable = true;
  };
}
