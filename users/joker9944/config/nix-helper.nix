_: {
  custom.command-collection-helper = {
    enable = true;
    help = "cli with a collection of common commands";

    config = {
      flake_local = "/home/joker9944/Workspace/nix-config";
      flake_git = "github:joker9944/nix-config";
    };

    branches.update =
      let
        mkUpdateLeaf = help: command: {
          inherit help;

          args = [ "context_settings={\"allow_extra_args\": True, \"ignore_unknown_options\": True}" ];

          switches = [
            {
              name = "ctx";
              type = "typer.Context";
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
            leafs = {
              local = mkUpdateLeaf "update NixOS from local config" "[\"sudo\", \"nixos-rebuild\", \"switch\", \"--flake\", config[\"flake_local\"]]";
              git = mkUpdateLeaf "update NixOS from git config" "[\"sudo\", \"nixos-rebuild\", \"switch\", \"--flake\", config[\"flake_git\"]]";
            };
          };

          home = {
            help = "update Home Manager";

            defaultLeaf = "local";
            leafs = {
              local = mkUpdateLeaf "update Home Manager from local config" "[\"home-manager\", \"switch\", \"--flake\", config[\"flake_local\"]]";
              git = mkUpdateLeaf "update Home Manager from git config" "[\"home-manager\", \"switch\", \"--flake\", config[\"flake_git\"]]";
            };
          };
        };
      };
  };
}
