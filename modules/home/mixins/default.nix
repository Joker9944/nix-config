{ flake, inputs, ... }@moduleArgs:
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
args.mkDefaultMixinModule
  {
    dir = ./.;
  }
  {
    imports = [ inputs.sops-nix.homeManagerModules.sops ];

    programs = {
      ssh = {
        enable = true;
        enableDefaultConfig = false;
      };

      home-manager.enable = true;

      git = {
        enable = true;
        settings = {
          init.defaultBranch = "main";
          pull.rebase = false;
          url."git@github.com:".insteadOf = "https://github.com/";
        };
      };
    };
  }
