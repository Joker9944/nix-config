{ mkDefaultMixinModule, ... }:
mkDefaultMixinModule {
  dir = ./.;
  prefix = [ "boot" ];
} { }
