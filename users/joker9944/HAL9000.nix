{ lib, config, pkgs, inputs, ...}:

{
  imports = [
    ./gnome.nix
    ./xdg.nix
    ./kanidm.nix
  ];

  home.packages = with pkgs; [
    fastfetch
    btop
    vscode

    libreoffice
    xournalpp

    spotify
    lutris
    discord
    telegram-desktop

    kubectl
    fluxcd
    kubernetes-helm
    talosctl
    talhelper
    lens

    sops
    age

    ventoy
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
        source <(talhelper completion bash)

        fastfetch
      '';

      shellAliases = {
        ls = "ls --color=auto --human-readable";
        ll = "ls --color=auto --human-readable -l --group-directories-first";
        la = "ls --color=auto --human-readable -l --all --group-directories-first";
        grep = "grep --color=auto";
        ".." = "cd ..";
        "..." = "cd ../..";
        cls = "clear";
        sops-encrypt = "sops --indent 2 --encrypt --in-place";
        sops-decrypt = "sops --indent 2 --decrypt --in-place";
        mktar = "tar -czvf";
        untar = "tar -xvf";
        nix-update = "sudo nixos-rebuild switch --flake /home/joker9944/Workspace/nix-config";
        home-update = "home-manager switch --flake /home/joker9944/Workspace/nix-config";
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
          program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
        };
        commit = {
          gpgsign = true;
        };
        user = {
          signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9R2V8FqyXifBoVO3OndfpRrqxdwK1H/3qlm645l7rg";
        };
        pull = {
          rebase = false;
        };
      };
    };

    ssh = {
      enable = true;
      extraConfig = ''
        Host *
          IdentityAgent ~/.1password/agent.sock
      '';
    };

    home-manager.enable = true;
  };

  home.stateVersion = "24.05";
}
