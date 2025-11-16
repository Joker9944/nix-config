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
      flakeLocal = "${config.home.homeDirectory}/Workspace/nix-config";
      flakeGit = config.services.home-manager.autoUpgrade.flake;
    in
    lib.mkIf cfg.enable {

      branches = {
        update =
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
                    type = "Annotated[str, typer.Option()] = \"${flakeDefault}\"";
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
                      flakeDefault = flakeLocal;
                    };

                    git = mkUpdateLeaf {
                      help = "update NixOS from git config";
                      inherit command;
                      flakeDefault = flakeGit;
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
                      flakeDefault = flakeLocal;
                    };

                    git = mkUpdateLeaf {
                      help = "update Home Manager from git config";
                      inherit command;
                      flakeDefault = flakeGit;
                    };

                    news = mkUpdateLeaf {
                      help = "show Home Manager news";
                      command = "[\"home-manager\", \"news\", \"--flake\", flake]";
                      flakeDefault = flakeGit;
                    };
                  };
              };
            };
          };

        nix = {
          help = "nix related helpers";

          branches = {
            options =
              let
                mkOptionsLeaf =
                  {
                    help,
                    flakeDefault,
                  }:
                  {
                    inherit help;

                    switches = [
                      {
                        name = "option_name";
                        type = "Annotated[str, typer.Argument(help = \"The option name to search for.\")]";
                      }
                      {
                        name = "flake";
                        type = "Annotated[str, typer.Option(help = \"Specify the flake containing NixOS configuration.\")] = \"${flakeDefault}\"";
                      }
                      {
                        name = "recursive";
                        type = "Annotated[bool, typer.Option(help = \"Print all the values at or below the specified path recursively.\")] = False";
                      }
                      {
                        name = "show_trace";
                        type = "Annotated[bool, typer.Option(help = \"Print eval trace.\")] = False";
                      }
                    ];

                    code = ''
                      subprocess.run([
                        "nixos-option",
                        "--flake", flake,
                        *(["--recursive"] if recursive else []),
                        *(["--show-trace"] if show_trace else []),
                        option_name
                      ])
                    '';
                  };
              in
              {
                help = "lookup option values";

                defaultLeaf = "local";

                leafs = {
                  local = mkOptionsLeaf {
                    help = "lookup option values from local config";
                    flakeDefault = flakeLocal;
                  };

                  git = mkOptionsLeaf {
                    help = "lookup option values from git config";
                    flakeDefault = flakeGit;
                  };
                };
              };
          };
        };
      };
    };
}
