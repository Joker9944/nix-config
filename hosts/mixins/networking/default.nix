{ mkDefaultMixinModule, ... }:
mkDefaultMixinModule {
  dir = ./.;
  prefix = [ "networking" ];
} { }
