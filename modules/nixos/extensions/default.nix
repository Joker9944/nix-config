{ flake }:
flake.lib.mkDefaultModule {
  dir = ./.;
  args = { inherit flake; };
} { }
