{ mkMixinModule, ... }:
mkMixinModule "ollama" {
  services.ollama.enable = true;
}
