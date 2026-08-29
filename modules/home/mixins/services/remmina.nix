{ mkMixinModule, ... }:
mkMixinModule "remmina" {
  services.remmina.enable = true;
}
