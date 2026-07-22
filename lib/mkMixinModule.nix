/**
  Build a single mixin module: declare its `enable` flag under
  `mixins.<prefix>.<name>` and gate `module` behind it, without repeating the
  option + `lib.mkIf` boilerplate.

  Partially applied with `{ config, prefix }` by the `mkDefaultMixinModule`
  aggregator helper (defined in each tree's top-level mixins `default.nix`) and
  threaded to each child, so leaves call `mkMixinModule "<name>" { … }` directly.

  # Type

  ```
  mkMixinModule :: { config, prefix :: [string]? } -> string -> module -> module
  ```
*/
{ self, lib, ... }:
{
  config,
  prefix ? [ ],
}:
name: module:
let
  optionPath = [ "mixins" ] ++ prefix ++ [ name ];
in
lib.recursiveUpdate
  {
    options = lib.setAttrByPath optionPath {
      enable = lib.mkEnableOption "${name} config mixin";
    };
  }
  (
    self.mkConditionalModule (lib.mkIf (lib.getAttrFromPath (optionPath ++ [ "enable" ]) config)) module
  )
