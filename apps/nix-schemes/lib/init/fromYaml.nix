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
file:
let
  json = pkgs.callPackage (
    { runCommand, remarshal, ... }:
    runCommand "${baseNameOf file}.json"
      {
        nativeBuildInputs = [ remarshal ];
        preferLocalBuild = true;
      }
      ''
        yaml2json "${file}" "$out"
      ''
  ) { };
in
builtins.fromJSON (lib.readFile json)
