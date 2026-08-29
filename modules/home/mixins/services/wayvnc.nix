{ mkMixinModule, ... }:
mkMixinModule "wayvnc" {
  services.wayvnc = {
    enable = true;
    settings = {
      address = "127.0.0.1";
      port = 5900;
    };
  };
}
