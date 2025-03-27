lib: rec {
  listDirs = dir: lib.attrNames (lib.filterAttrs (_: type: lib.elem type ["directory"]) (builtins.readDir dir));

  listFiles = dir: lib.attrNames (lib.filterAttrs (_: type: lib.elem type ["regular" "symlink"]) (builtins.readDir dir));

  importFiles = dir:
    lib.listToAttrs (map (filename: {
      name = lib.removeSuffix ".nix" filename;
      value = import (lib.path.append dir filename);
    }) (listFiles dir));
}
