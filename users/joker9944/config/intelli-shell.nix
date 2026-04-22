{ lib, config, ... }:
{
  config = lib.mkIf config.programs.intelli-shell.enable {
    programs = {
      intelli-shell = {
        settings.gist = {
          id = "8a3b4e4d4a58e3d71c939fcaab658aa0";
          token = ""; # GIST_TOKEN env variables takes precedence
        };

        commands = [
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

      bash.initExtra = ''
        export GIST_TOKEN="$(cat ${config.sops.secrets."tokens/intelli-shell".path})"
      '';
    };

    sops.secrets."tokens/intelli-shell" = { };
  };
}
