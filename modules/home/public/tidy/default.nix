{ flake, ... }@args:
flake.lib.modules.mkDefaultModule {
  dir = ./.;
  inherit args;
  exclude = [ ./timer.nix ];
} { }
