{ flake }:
{ lib, ... }:
{
  imports =
    lib.pipe
      {
        dir = ./.;
        exclude = [ ./default.nix ];
      }
      [
        flake.lib.ls
        (lib.map (path: lib.modules.importApply path { inherit flake; }))
      ];
}
