{ mkDefaultFlakeModule, ... }:
mkDefaultFlakeModule {
  dir = ./.;
  exclude = [ ./timer.nix ];
} { }
