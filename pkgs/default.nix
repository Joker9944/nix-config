{
  flake,
  lib,
  pkgs,
  ...
}@args:
(lib.pipe
  {
    dir = ./.;
    types = [ "regular" ];
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
)
// (lib.pipe
  {
    dir = ./.;
    types = [ "directory" ];
  }
  [
    flake.lib.ls
    (lib.map (path: import path args))
    (lib.foldl (acc: attr: acc // attr) { })
  ]
)
