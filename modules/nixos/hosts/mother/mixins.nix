_: {
  mixins = {
    hardware = {
      intelCpu.enable = true;

      # No nvidiaCuda: the GPU is here for NVENC/NVDEC transcoding, which comes
      # from the driver. cudaSupport would rebuild the package set for nothing.
      nvidia.enable = true;
    };

    services = {
      k3s.enable = true;
      zfs.enable = true;
      nfs.enable = true;
    };
  };
}
