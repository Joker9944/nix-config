{ lib, config, ... }:
{
  options.mixins.helpers.nix =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "nix helper mixin";
    };

  config.custom.command-collection =
    let
      cfg = config.mixins.helpers.nix;
    in
    lib.mkIf cfg.enable {
      config = {
        flake_local = "${config.home.homeDirectory}/Workspace/nix-config";
        flake_git = config.services.home-manager.autoUpgrade.flake;
      };

      branches.update =
        let
          mkUpdateLeaf =
            {
              help,
              command,
              flakeDefault,
            }:
            {
              inherit help;

              args = [
                "context_settings={\"allow_extra_args\": True, \"ignore_unknown_options\": True, \"help_option_names\": [\"--util-help\"]}"
              ];

              switches = [
                {
                  name = "ctx";
                  type = "typer.Context";
                }
                {
                  name = "flake";
                  type = "Annotated[str, typer.Option()] = ${flakeDefault}";
                }
              ];

              code = ''
                subprocess.run(${command} + ctx.args)
              '';
            };
        in
        {
          help = "update system components";

          branches = {
            nix = {
              help = "update NixOS";

              defaultLeaf = "local";

              leafs =
                let
                  command = "[\"sudo\", \"nixos-rebuild\", \"switch\", \"--flake\", flake]";
                in
                {
                  local = mkUpdateLeaf {
                    help = "update NixOS from local config";
                    inherit command;
                    flakeDefault = "config[\"flake_local\"]";
                  };

                  git = mkUpdateLeaf {
                    help = "update NixOS from git config";
                    inherit command;
                    flakeDefault = "config[\"flake_git\"]";
                  };
                };
            };

            home = {
              help = "update Home Manager";

              defaultLeaf = "local";

              leafs =
                let
                  command = "[\"home-manager\", \"switch\", \"--flake\", flake]";
                in
                {
                  local = mkUpdateLeaf {
                    help = "update Home Manager from local config";
                    inherit command;
                    flakeDefault = "config[\"flake_local\"]";
                  };

                  git = mkUpdateLeaf {
                    help = "update Home Manager from git config";
                    inherit command;
                    flakeDefault = "config[\"flake_git\"]";
                  };

                  news = mkUpdateLeaf {
                    help = "show Home Manager news";
                    command = "[\"home-manager\", \"news\", \"--flake\", flake]";
                    flakeDefault = "config[\"flake_git\"]";
                  };
                };
            };
          };
        };
    };
}
