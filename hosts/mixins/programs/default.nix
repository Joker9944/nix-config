{ mkDefaultMixinModule, ... }:
mkDefaultMixinModule {
  dir = ./.;
  prefix = [ "programs" ];
} { }
