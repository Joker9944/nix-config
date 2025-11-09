{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.programs.bash.enable {
    programs.bash = {
      enableCompletion = true;

      initExtra = ''
        nix-search() {
          nix-instantiate --eval-only --expr "(import <nixpkgs> {}).$1.outPath" | cut -d '"' -f 2
        }

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
        mktar = "tar -czvf"; # cSpell:words mktar cSpell:ignore czvf
        untar = "tar -xvf"; # cSpell:words untar
        open = "xdg-open";
      };
    };
  };
}
