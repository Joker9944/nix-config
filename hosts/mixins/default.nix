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
      custom.lib.mkDefaultModule (
        lib.recursiveUpdate fnArgs {
          args = self // {
            mkMixinModule = custom.lib.mkMixinModule { inherit config prefix; };
          };
        }
      );
  });
in
args.mkDefaultMixinModule { dir = ./.; } { }
