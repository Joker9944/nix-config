{ mkMixinModule, ... }:
mkMixinModule "systemdBoot" {
  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
    configurationLimit = 10;
  };
}
