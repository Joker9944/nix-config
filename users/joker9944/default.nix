{
  lib,
  pkgs,
  osConfig,
  utility,
  ...
}:
let
  hostModule = lib.path.append ./. "hosts/${osConfig.networking.hostName}.nix";
in
{
  inherit (osConfig) desktopEnvironment;

  # TODO auto import
  imports =
    (utility.custom.ls.lookup {
      dir = ./config;
    })
    ++ lib.optional (builtins.pathExists hostModule) hostModule; # Import matching host modules

  home.packages = with pkgs; [
    fastfetch
    imagemagick
    tree
    trash-cli

    meld
    lens

    libreoffice
    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_CH
    papers

    joplin-desktop
    inkscape
    audacity

    vlc

    minio-client
  ];

  xdg = {
    autostart = {
      enable = true;

      entries = [ "${pkgs.telegram-desktop}/share/applications/org.telegram.desktop.desktop" ];
    };

    mimeApps.enable = true;
  };

  programs = {
    bash.enable = true;

    vscode.enable = true;

    telegram.enable = true;
    spotify.enable = true;
    discord = {
      enable = true;
      package = pkgs.vesktop;
    };

    git = {
      enable = true;
      userEmail = "9194199+Joker9944@users.noreply.github.com";
      userName = "Joker9944";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = false;
      };
    };

    ssh.enable = true;

    _1password = {
      sshIdentityAgentHosts = [ "*" ];

      sshAgentConfig = {
        ssh-keys = [
          {
            vault = "Private";
            item = "joker9944@" + osConfig.networking.hostName;
          }
        ];
      };

      autostart.enable = true;
    };

    home-manager.enable = true;
  };

  home.stateVersion = "24.05";
}
