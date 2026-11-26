{ mkMixinModule, ... }:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  withFd = lib.mkIf config.programs.fd.enable;
  inherit (config.programs) fish atuin;
in
mkMixinModule "fzf" {
  programs = {
    fzf = {
      enable = true;
      # fish gets fzf-fish instead
      enableFishIntegration = !fish.enable;
      defaultCommand = withFd "fd --type f";
      fileWidgetCommand = withFd "fd --type f";
      changeDirWidgetCommand = withFd "fd --type d";
    };

    fish = lib.mkIf fish.enable {
      plugins = [
        {
          name = "fzf-fish";
          inherit (pkgs.fishPlugins.fzf-fish) src;
        }
      ];

      interactiveShellInit = ''
        set -g fzf_preview_file_cmd ${lib.getExe pkgs.bat} --style=numbers --color=always
        fzf_configure_bindings --variables=ctrl-alt-v ${lib.optionalString atuin.enable "--history="}
      '';
    };
  };

  home.sessionVariables = lib.mkIf atuin.enable {
    FZF_CTRL_R_COMMAND = "";
  };
}
