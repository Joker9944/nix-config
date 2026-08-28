/**
  Select a module by the class of the evaluation loading it, so one module value
  can be exported to several trees and contribute the right body to each.

  The key is the module class as the module system spells it — `homeManager`,
  not this repo's `home` directory naming. A key that names no class is a typo
  and throws; a class with no key is a no-op, so a module that only configures
  one tree needs no empty branch for the other.

  The selected branch is placed in `imports` rather than returned, so it may be
  an attrset, a path or a function.

  `class` is `null` outside a classed evaluation — a bare `lib.evalModules`, or
  anything inside a `types.submodule`, which does not inherit its parent's class.
  That is a no-op too.

  # Type

  ```
  mkClassModule :: string | null -> attrsOf module -> module
  ```

  # Arguments

  - `class`: The `_class` module argument of the loading evaluation
  - `modules`: Module per class, keyed by class name

  # Example

  ```nix
  { _class, ... }:
  mkClassModule _class {
    nixos = {
      options.custom.foo = { … };
      config.services.foo.enable = true;
    };

    homeManager = ./home.nix;
  }
  ```
*/
{ lib, ... }:
class: modules:
let
  known = [
    "nixos"
    "homeManager"
  ];

  unknown = lib.subtractLists known (lib.attrNames modules);
in
lib.throwIf (unknown != [ ])
  "mkClassModule: not a module class: ${lib.concatStringsSep ", " unknown} (known: ${lib.concatStringsSep ", " known})"
  {
    imports = lib.optional (class != null && modules ? ${class}) modules.${class};
  }
