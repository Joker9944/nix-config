/**
  Wrap a module's configuration in a condition function.
  Handles modules with explicit `config` attribute, modules with only structural
  top-level attributes (imports, options, meta, freeformType), shorthand modules,
  and mixed modules that combine structural attributes with shorthand config.

  # Type

  ```
  mkConditionalModule :: (attrs -> attrs) -> module -> module
  ```

  # Arguments

  - `condition`: Function to wrap config (e.g., `lib.mkIf someBool`)
  - `module`: NixOS/home-manager module to wrap

  # Example

  ```nix
  mkConditionalModule (lib.mkIf config.programs.foo.enable) {
    programs.bar.enable = true;
  }
  => { config = lib.mkIf config.programs.foo.enable { programs.bar.enable = true; }; }
  ```

  ```nix
  mkConditionalModule (lib.mkIf config.programs.foo.enable) {
    imports = [ ./other.nix ];
    programs.bar.enable = true;
  }
  => { imports = [ ./other.nix ]; config = lib.mkIf config.programs.foo.enable { programs.bar.enable = true; }; }
  ```
*/
{ lib, ... }:
condition: module:
let
  # Top-level keys the module system treats as structural (never part of config).
  # Mirrors the keys stripped in the shorthand branch of lib/modules.nix plus
  # options/meta which are also never config.
  structuralKeys = [
    "imports"
    "options"
    "meta"
    "freeformType"
    "config"
    # Internal module system keys
    "_class"
    "_file"
    "key"
    "disabledModules"
    "require"
  ];
  structural = lib.filterAttrs (name: _: lib.elem name structuralKeys) module;
  shorthand = lib.filterAttrs (name: _: !lib.elem name structuralKeys) module;
in
# Explicit form: module has a top-level `config` key
if lib.hasAttr "config" module then
  structural // { config = condition module.config; }
# Shorthand form (possibly mixed with structural keys like `imports`):
# collect all non-structural keys and wrap them as config
else if shorthand != { } then
  structural // { config = condition shorthand; }
# Pure structural only (imports/options/meta with no config): nothing to wrap
else
  module
