{
  flake,
  libUtil,
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
    libUtil.files.list
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
    libUtil.files.list
    (lib.map (path: import path args))
    (lib.foldl (acc: attr: acc // attr) { })
  ]
)
