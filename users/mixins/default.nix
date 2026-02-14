{
  inputs,
  custom,
  ...
}:
{
  imports =
    (custom.lib.ls {
      dir = ./.;
      exclude = [ ./default.nix ];
    })
    ++ [ inputs.sops-nix.homeManagerModules.sops ];

  # Set args inherited from mkHomeConfiguration
  home = {
    inherit (custom.config) username;
    homeDirectory = "/home/${custom.config.username}";
  };

  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;
    };

    home-manager.enable = true;

    git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        pull.rebase = false;
        url."git@github.com:".insteadOf = "https://github.com/";
      };
    };

    # TODO move to better location
    intelli-shell.commands = [
      {
        command = "git commit --amend --no-edit";
        alias = "git commit amend";
        description = "Amend the current commit without editing the message";
        tags = [ "git" ];
      }
      {
        command = "sudo nixos-rebuild switch --flake {{~/Workspace/nix-config|github:joker9944/nix-config}}";
        alias = "nix update";
        description = "Update nix with flake";
        tags = [ "nixos" ];
      }
      {
        command = "home-manager switch --flake {{~/Workspace/nix-config|github:joker9944/nix-config}}";
        alias = "home update";
        description = "Update home with flake";
        tags = [ "hm" ];
      }
      {
        command = "home-manager news --flake {{~/Workspace/nix-config|github:joker9944/nix-config}}";
        alias = "home news";
        description = "Show home news";
        tags = [ "hm" ];
      }
      {
        command = "nix repl {{nixpkgs|github:joker9944/nix-config}}";
        alias = "nix shell";
        description = "Start interactive nix shell";
        tags = [ "nix" ];
      }
      {
        command = "nix search {{nixpkgs|github:joker9944/nix-config}} {{regex}}";
        alias = "nix search package";
        description = "Search installable for a nix package";
        tags = [ "nix" ];
      }
      {
        command = "nixos-option --flake {{~/Workspace/nix-config|github:joker9944/nix-config}} {{option}}";
        alias = "nix search option";
        description = "Search set option values from flake";
        tags = [ "nix" ];
      }
      {
        command = "sops --indent {{2}} --decrypt --in-place {{file}}";
        alias = "sops decrypt";
        description = "Decrypt file with sops";
        tags = [ "sops" ];
      }
      {
        command = "sops --indent {{2}} --encrypt --in-place {{file}}";
        alias = "sops encrypt";
        description = "Encrypt file with sops";
        tags = [ "sops" ];
      }
    ];
  };
}
