{
  flake,
  lib,
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
      value = import path;
    }))
    lib.listToAttrs
  ]
