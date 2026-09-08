{ mkMixinModule, ... }:
{
  lib,
  config,
  pkgs,
  ...
}:
mkMixinModule "nvidia" {
  custom.nixpkgsCompat = {
    # nvidia-x11 is the whole proprietary driver — kernel module source, GSP
    # firmware, and the userspace libs including NVML and NVENC/NVDEC. The name
    # is historical; a headless host needs it just the same.
    allowUnfreePackages = [
      "nvidia-x11"
    ]
    ++ lib.optional config.hardware.nvidia.nvidiaSettings "nvidia-settings";

    # Not for cudaSupport — nvtopPackages.nvidia below pulls cuda-merged, so
    # the driver alone needs this.
    allowUnfreeLicenses = [ "CUDA EULA" ];
  };

  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    # nixpkgs defaults this on; it is a GUI tool, so headless hosts skip it.
    nvidiaSettings = lib.mkDefault false;
  };

  # Not implied by hardware.nvidia, and without it the userspace driver stack
  # (including NVENC/NVDEC) is not set up.
  hardware.graphics.enable = true;

  # Selects the proprietary module. Independent of services.xserver.enable, so
  # this is also how a headless host loads the driver.
  services.xserver.videoDrivers = [ "nvidia" ];

  environment.systemPackages = [ pkgs.nvtopPackages.nvidia ];
}
