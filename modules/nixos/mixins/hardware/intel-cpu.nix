{ mkMixinModule, ... }:
_:
mkMixinModule "intelCpu" {
  hardware.cpu.intel.updateMicrocode = true;

  # Its own capability rather than part of `battery`: thermald's cpuid check
  # fails the unit on non-Intel silicon, and the package is x86-only.
  services.thermald.enable = true;
}
