{ mkMixinModule, ... }:
_:
mkMixinModule "intelCpu" {
  boot.kernelModules = [ "kvm-intel" ];

  hardware.cpu.intel.updateMicrocode = true;
}
