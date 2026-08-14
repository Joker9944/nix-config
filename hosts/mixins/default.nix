{
  lib,
  config,
  custom,
  ...
}:
let
  args = lib.fix (self: {
    mkDefaultMixinModule =
      {
        prefix ? [ ],
        ...
      }@fnArgs:
      custom.lib.modules.mkDefaultModule (
        lib.recursiveUpdate fnArgs {
          args = self // {
            mkMixinModule = custom.lib.modules.mkMixinModule { inherit config prefix; };
          };
        }
      );
  });
in
args.mkDefaultMixinModule { dir = ./.; } { }
