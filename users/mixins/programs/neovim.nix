{ mkMixinModule, ... }:
{ lib, pkgs, ... }:
mkMixinModule "neovim" {
  programs.neovim = {
    enable = true;

    # setup defaults
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # WORKAROUND Has to be set since `home.stateVersion` is less than "26.05"
    withRuby = false;
    # WORKAROUND Has to be set since `home.stateVersion` is less than "26.05"
    withPython3 = false;

    initLua = ''
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
}
