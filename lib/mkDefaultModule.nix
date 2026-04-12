/**
  Extend a module's imports with all sibling files in a directory, excluding
  `default.nix` itself. Intended for use in `default.nix` files that act as
  aggregation points for a directory of modules.

  # Type

  ```
  mkDefaultModule :: { dir :: path, exclude :: [path]?, args :: attrs? } -> module -> module
  ```

  # Arguments

  - `dir`: Directory path whose contents are appended to the module's imports
  - `exclude` (optional): Additional paths to exclude from the scan, on top of `default.nix`
  - `args` (optional): When set, each discovered file is imported via
    `lib.modules.importApply path args` instead of a bare path import, allowing
    extra arguments to be passed to child modules
  - `module`: NixOS/home-manager module to extend

  # Example

  ```nix
  # options/default.nix — auto-imports binds.nix, style.nix, terminal.nix, etc.
  mkDefaultModule { dir = ./.; } {
    imports = [ someOtherModule ];
  }
  => { imports = [ someOtherModule /path/to/options/binds.nix /path/to/options/style.nix ... ]; }
  ```
*/
{ self, lib, ... }:
{
  dir,
  exclude ? [ ],
  args ? null,
}:
module:
let
  lsArgs = {
    inherit dir;
    exclude = exclude ++ [ (lib.path.append dir "default.nix") ];
  };
in
module
// {
  imports =
    module.imports or [ ]
    ++ (
      if args == null then
        self.ls lsArgs
      else
        lib.pipe lsArgs [
          self.ls
          (lib.map (path: lib.modules.importApply path args))
        ]
    );
}
