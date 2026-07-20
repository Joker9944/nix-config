_:
{ config, custom, ... }:
custom.lib.mkMixinsModule {
  inherit config;
  dir = ./.;
  prefix = [ "programs" ];
} { }
