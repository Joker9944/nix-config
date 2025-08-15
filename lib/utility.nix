lib: rec {
  ls = rec {
    filters = {
      all = ["regular" "directory" "symlink" "unknown"];
      normal = ["regular" "directory" "symlink"];
      dirs = ["directory"];
      files = ["regular" "symlink"];
    };

    lookup = {
      dir,
      types ? filters.normal,
      exclude ? [],
    } @ args: let
      filterByType = lib.attrsets.filterAttrs (_: type: lib.lists.elem type types);
      stripTypes = lib.attrsets.attrNames;
      convertToPaths = lib.lists.map (filename: lib.path.append dir filename);
      filterByExclusions = lib.lists.filter (path: ! lib.lists.elem path exclude);

      content = builtins.readDir dir;
      filteredByType =
        if types != filters.all
        then filterByType content
        else content;
      filenames = stripTypes filteredByType;
      paths = convertToPaths filenames;
      filteredByExcludes =
        if lib.lists.length exclude != 0
        then filterByExclusions paths
        else paths;
    in
      filteredByExcludes;
  };



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

  mkConditionalModule = condition: module:
  # Check if the module has the config keyword attribute
    if lib.attrsets.hasAttr "config" module
    # The module has the config keyword attribute so wrap it in the condition
    then module // {config = condition module.config;}
    # Check if there are other toplevel keyword attributes present
    else if lib.attrsets.hasAttr "imports" module || lib.attrsets.hasAttr "options" module
    # The module has other toplevel keyword attributes indicating no config present at all
    then module
    # No other toplevel keyword attributes present indicating toplevel configuration
    else {config = condition module;};

  mkHyprlandModule = cfg: mkConditionalModule (lib.mkIf cfg.desktopEnvironment.hyprland.enable);
}
