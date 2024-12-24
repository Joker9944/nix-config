lib: with lib; with builtins; {
  listDirs = dir: attrNames ( filterAttrs ( _: type: elem type [ "directory" ] ) ( readDir dir ));

  listFiles = dir: attrNames ( filterAttrs ( _: type: elem type [ "regular" "symlink" ] ) ( readDir dir ));

  attrsToValuesList = attrs: map ( attr: attr.value ) ( attrsToList attrs );
}
