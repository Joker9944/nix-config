{ flake, ... }@moduleArgs:
{
  lib,
  config,
  ...
}:
let
  args = lib.fix (self: {
    mkDefaultMixinModule =
      {
        prefix ? [ ],
        ...
      }@fnArgs:
      flake.lib.modules.mkDefaultModule (
        lib.recursiveUpdate fnArgs {
          args =
            moduleArgs
            // self
            // {
              mkMixinModule = flake.lib.modules.mkMixinModule { inherit config prefix; };
            };
        }
      );
  });
in
args.mkDefaultMixinModule { dir = ./.; } { }
