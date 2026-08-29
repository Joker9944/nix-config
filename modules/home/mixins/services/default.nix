{ mkDefaultMixinModule, ... }:
mkDefaultMixinModule {
  dir = ./.;
  prefix = [ "services" ];
} { }
