{ mkDefaultMixinModule, ... }:
mkDefaultMixinModule {
  dir = ./.;
  prefix = [ "hardware" ];
} { }
