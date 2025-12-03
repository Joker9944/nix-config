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
