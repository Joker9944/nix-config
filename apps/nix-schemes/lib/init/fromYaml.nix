{ lib, pkgs, ... }:
name: file:
let
  json = pkgs.callPackage (
    { runCommand, remarshal, ... }:
    runCommand "${name}.json"
      {
        nativeBuildInputs = [ remarshal ];
        value = lib.readFile file;
        passAsFile = [ "value" ];
        preferLocalBuild = true;
      }
      ''
        yaml2json "$valuePath" "$out"
      ''
  ) { };
in
builtins.fromJSON (lib.readFile json)
