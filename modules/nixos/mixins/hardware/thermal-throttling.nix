{ mkMixinModule, ... }:
{ config, ... }:
mkMixinModule "thermalThrottling" {
  # thermald is the Intel mechanism — its cpuid check fails the unit elsewhere,
  # and AMD has no standard equivalent.
  services.thermald.enable = config.mixins.hardware.intelCpu.enable;
}
