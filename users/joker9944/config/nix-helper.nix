{
  custom.command-collection = {
    enable = true;

    name = "cc";
    help = "cli with a collection of common commands";

    config = {
      flake_local = "/home/joker9944/Workspace/nix-config";
      flake_git = "github:joker9944/nix-config";
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
