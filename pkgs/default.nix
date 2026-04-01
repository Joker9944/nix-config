{
  flake,
  lib,
  pkgs,
  ...
}:
lib.pipe
  {
    dir = ./.;
    exclude = [ ./default.nix ];
  }
  [
    flake.lib.ls
    (lib.map (path: {
      name = lib.strings.removeSuffix ".nix" (baseNameOf path);
      value = pkgs.callPackage path { inherit flake; };
    }))
    lib.listToAttrs
  ]
