{ lib, ... }:
let
  templates = import ./templates;
in
{
  inherit templates;
  mkDiskoLayout = import ./mkDiskoLayout.nix { inherit lib templates; };
}
