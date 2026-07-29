/**
  Render a disko `devices` layout from a per-host config and a template.

  The template defaults to `templates.version1`. Host size defaults mirror the
  old mixin options (boot 500M, swap disabled, main fills the disk).

  # Type

  ```
  mkDiskoLayout :: { config :: { main :: { name, size ? {...} } }, template ? } -> attrs
  ```
*/
{ lib, templates }:
{
  config,
  template ? templates.version1,
}:
let
  cfg = lib.recursiveUpdate {
    main.size = {
      boot = "500M";
      swap = null;
      main = "100%";
    };
  } config;
in
template {
  inherit lib;
  config = cfg;
}
