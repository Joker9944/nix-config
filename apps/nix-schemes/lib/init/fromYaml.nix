/**
  Parse a YAML file into a Nix attribute set.
  Requires pkgs (impure).

  # Type

  ```
  fromYaml :: string -> path -> attrs
  ```

  # Example

  ```nix
  fromYaml "my-config" ./config.yaml
  => { key = "value"; ... }
  ```
*/
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
