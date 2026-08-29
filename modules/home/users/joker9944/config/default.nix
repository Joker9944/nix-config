{ flake, ... }@args:
flake.lib.modules.mkDefaultModule {
  dir = ./.;
  inherit args;
} { }
