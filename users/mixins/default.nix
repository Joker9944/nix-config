{
  lib,
  inputs,
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
args.mkDefaultMixinModule
  {
    dir = ./.;
  }
  {
    imports = [ inputs.sops-nix.homeManagerModules.sops ];

    # Set args inherited from mkHomeConfiguration
    home = {
      inherit (custom.config) username;
      homeDirectory = "/home/${custom.config.username}";
    };

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
