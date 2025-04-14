{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  hostname,
  ...
}: let
  hostModule = lib.path.append ./. "hosts/${hostname}.nix";
in {
  imports =
    [
      ./config/bash.nix
      ./config/cloud.nix
      ./config/font.nix
      ./config/gnome.nix
      ./config/kanidm.nix
      ./config/xdg.nix
    ]
    ++ (
      if (builtins.pathExists hostModule)
      then [hostModule]
      else []
    );

  home.packages = with pkgs; [
    fastfetch
    btop
    imagemagick
    tree

    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    jetbrains.webstorm
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

    spotify
    lutris
    vlc

    discord
    telegram-desktop

    nextcloud-client
    minio-client

    ventoy
  ];

  programs = {
    bash.enable = true;

    vscode.enable = true;

    git = {
      enable = true;
      userEmail = "9194199+Joker9944@users.noreply.github.com";
      userName = "Joker9944";
      extraConfig.pull.rebase = false;
    };

    ssh.enable = true;

    _1password = {
      sshIdentityAgentHosts = ["*"];
      gitSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9R2V8FqyXifBoVO3OndfpRrqxdwK1H/3qlm645l7rg";
    };

    home-manager.enable = true;
  };

  home.stateVersion = "24.05";
}
