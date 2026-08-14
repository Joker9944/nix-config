{ flake, ... }@moduleArgs:
{ lib, ... }:
let
  args = lib.fix (
    self:
    moduleArgs
    // {
      mkDefaultFlakeModule =
        fnArgs: flake.lib.modules.mkDefaultModule (lib.recursiveUpdate fnArgs { args = self; });
    }
  );
in
args.mkDefaultFlakeModule { dir = ./.; } { }
