{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.programs.neovim =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "neovim config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.neovim;
    in
    lib.mkIf cfg.enable {
      programs.neovim = {
        enable = true;

        # setup defaults
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;

        extraLuaConfig = ''
          vim.o.list = true;
          vim.o.listchars = 'tab:» ,lead:•,trail:•'
        '';

        coc = {
          enable = true;
          settings = {
            languageserver = {
              nix = {
                command = lib.getExe pkgs.nil;
                filetypes = [ "nix" ];
                rootPatterns = [ "flake.nix" ];
                settings.nil = {
                  formatting.command = [ (lib.getExe pkgs.nixfmt) ];
                  nix.flake = {
                    autoArchive = true;
                    autoEvalInputs = true;
                  };
                };
              };
            };
          };
        };
      };
    };
}
