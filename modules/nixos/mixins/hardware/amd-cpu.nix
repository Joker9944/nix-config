{ mkMixinModule, ... }:
_:
mkMixinModule "amdCpu" {
  boot.kernelModules = [ "kvm-amd" ];

  hardware.cpu.amd.updateMicrocode = true;
}
