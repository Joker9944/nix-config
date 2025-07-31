lib: rec {
  listDirs = dir: lib.attrNames (lib.filterAttrs (_: type: lib.elem type ["directory"]) (builtins.readDir dir));

  listFiles = dir: lib.attrNames (lib.filterAttrs (_: type: lib.elem type ["regular" "symlink"]) (builtins.readDir dir));

  listFilesRelative = dir: lib.map (file: lib.path.append dir file) (listFiles dir);

  applyFunctionRecursive = dir: fun:
    lib.attrsets.listToAttrs (
      lib.lists.map (entry: {
        name = lib.strings.removeSuffix ".nix" entry.name;
        value =
          if entry.value == "directory"
          then applyFunctionRecursive (lib.path.append dir entry.name) fun
          else fun (lib.path.append dir entry.name);
      })
      (lib.attrsets.attrsToList (builtins.readDir dir))
    );
}
