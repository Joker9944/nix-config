{ config, pkgs, inputs, ...}:

{
  home.username = "joker9944";
  home.homeDirectory = "/home/joker9944";

  home.packages = with pkgs; [
    fastfetch
    btop
    vscode

    baobab

    libreoffice
    xournalpp
    firefox
    _1password-gui

    spotify

    steam
    gamemode
    gamescope
    lutris
    discord

    kubectl
    fluxcd
    kubernetes-helm
    talosctl
    # talhelper
    openlens

    kanidm
  ];

  programs = {

    bash = {
      enable = true;
      enableCompletion = true;

      bashrcExtra = ''
      # Command Completion
      source <(kubectl completion bash)
      source <(helm completion bash)
      source <(flux completion bash)
      source <(talosctl completion bash)
      # source <(talhelper completion bash)

      fastfetch
      '';

      shellAliases = {
        ls = "ls -ah";
        ll = "ls -ahl";
        ".." = "cd ..";
        "..." = "cd ../..";
        cls = "clear";
        sops-encrypt = "sops --indent 2 --encrypt --in-place";
        sops-decrypt = "sops --indent 2 --decrypt --in-place";
        mktar = "tar -czvf";
        untar = "tar -xvf";
      };
    };

    git = {
      enable = true;
      userEmail = "9194199+Joker9944@users.noreply.github.com";
      userName = "Joker9944";
      extraConfig = {
        gpg = {
          format = "ssh";
        };
        "gpg \"ssh\"" = {
          program = "/opt/1Password/op-ssh-sign";
        };
        user = {
          signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9R2V8FqyXifBoVO3OndfpRrqxdwK1H/3qlm645l7rg";
        };
      };
    };

    ssh = {
      enable = true;
      extraConfig = ''IdentityAgent ~/.1password/agent.sock'';
    };

    home-manager.enable = true;
  };

  home.stateVersion = "24.05";
}
