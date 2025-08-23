{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  hostModule = lib.path.append ./. "hosts/${osConfig.networking.hostName}.nix";
in
{
  inherit (osConfig) desktopEnvironment;

  # TODO auto import
  imports = [
    ./config/bash.nix
    ./config/cloud.nix
    ./config/font.nix
    ./config/gnome.nix
    ./config/hyprland
    ./config/jetbrains.nix
    ./config/kanidm.nix
    ./config/kde-plasma.nix
    ./config/vscode.nix
  ]
  ++ lib.optional (builtins.pathExists hostModule) hostModule;

  home.packages = with pkgs; [
    fastfetch
    imagemagick
    tree

    meld
    lens

    libreoffice
    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_CH

    joplin-desktop
    xournalpp
    inkscape
    audacity

    vlc

    nextcloud-client
    minio-client
  ];

  xdg.autostart = {
    enable = true;

    entries = [ "${pkgs.telegram-desktop}/share/applications/org.telegram.desktop.desktop" ];
  };

  programs = {
    bash.enable = true;

    vscode.enable = true;

    telegram.enable = true;
    spotify.enable = true;
    discord.enable = true;

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
