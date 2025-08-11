{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.programs.bash.enable {
    programs.bash = {
      enableCompletion = true;

      initExtra = ''
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
        open = "xdg-open";
      };
    };
  };
}
