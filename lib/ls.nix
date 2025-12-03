{ lib, ... }:
lib.fix (self: {
  filters = {
    all = [
      "regular"
      "directory"
      "symlink"
      "unknown"
    ];
    normal = [
      "regular"
      "directory"
      "symlink"
    ];
    dirs = [ "directory" ];
    files = [
      "regular"
      "symlink"
    ];
  };

  lookup =
    {
      dir,
      types ? self.filters.normal,
      exclude ? [ ],
    }:
    let
      filterByType = lib.attrsets.filterAttrs (_: type: lib.lists.elem type types);
      stripTypes = lib.attrsets.attrNames;
      convertToPaths = lib.lists.map (filename: lib.path.append dir filename);
      filterByExclusions = lib.lists.filter (path: !lib.lists.elem path exclude);

      content = builtins.readDir dir;
      filteredByType = if types != self.filters.all then filterByType content else content;
      filenames = stripTypes filteredByType;
      paths = convertToPaths filenames;
      filteredByExcludes = if lib.lists.length exclude != 0 then filterByExclusions paths else paths;
    in
    filteredByExcludes;
})
