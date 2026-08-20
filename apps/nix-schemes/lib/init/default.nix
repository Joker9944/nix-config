/**
  Initialize libSchemes with pkgs to enable impure functions.
  Returns the full libSchemes with additional functions that require pkgs.

  # Type

  ```
  init :: pkgs -> libSchemes
  ```

  # Example

  ```nix
  let
    libSchemes = inputs.nix-schemes.lib.libSchemes.init pkgs;
  in
  libSchemes.mkGtkThemeCss { ... }
  ```
*/
{
  lib,
  libSelf,
  libUtil,
  ...
}@args:
pkgs:
# Members land at the root of the returned lib, not under `init` — hence the second
# fixed point, and members reaching siblings as `libSelf.<name>`.
(lib.removeAttrs libSelf [ "init" ])
// (lib.fix (
  initSelf:
  libUtil.mkLibNamespace {
    context = ./.;
    args = args // {
      inherit pkgs;
      libSelf = lib.recursiveUpdate libSelf initSelf;
    };
  }
))
