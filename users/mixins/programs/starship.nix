{ mkMixinModule, ... }:
mkMixinModule "starship" {
  programs.starship = {
    enable = true;
    presets = [ "nerd-font-symbols" ];
  };
}
