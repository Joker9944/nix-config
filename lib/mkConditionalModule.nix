/**
  Wrap a module's configuration in a condition function.
  Handles modules with explicit `config` attribute, modules with only other
  top-level attributes (meta, imports, options), and shorthand modules.

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
*/
{ lib, ... }:
condition: module:
# Check if the module has the config keyword attribute
if
  lib.hasAttr "config" module
# The module has the config keyword attribute so wrap it in the condition
then
  module // { config = condition module.config; }
# Check if there are other top level keyword attributes present
else if
  lib.hasAttr "meta" module || lib.hasAttr "imports" module || lib.hasAttr "options" module
# The module has other top level keyword attributes indicating no config present at all
then
  module
# No other top level keyword attributes present indicating top level configuration
else
  { config = condition module; }
