{ lib, config, ... }:
{
  options.mixins.programs.vim =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "vim config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.vim;
    in
    lib.mkIf cfg.enable {
      programs = {
        # Disable nano and switch to vim as default
        nano.enable = lib.mkDefault false;
        vim = {
          enable = lib.mkDefault true;
          defaultEditor = lib.mkDefault true;
        };
      };
    };
}
