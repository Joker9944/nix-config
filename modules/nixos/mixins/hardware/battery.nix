{ mkMixinModule, ... }:
_:
mkMixinModule "battery" {
  # Read by the home tree: the yas battery module is an AstalBattery (UPower)
  # client, and that client is constructed whether or not the module renders.
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
}
