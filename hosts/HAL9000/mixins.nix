{
  mixins = {
    boot.windowsSupport.enable = true;

    hardware.nvidia.enable = true;

    programs = {
      ffmpeg.enable = true;
      steam.enable = true;
    };

    virtualisation.docker.enable = true;
  };
}
