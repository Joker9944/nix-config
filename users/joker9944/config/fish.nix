{
  programs.fish.completions = {
    nixos = ''
      complete -c nixos-rebuild -r -n '__fish_seen_subcommand_from switch' -l flake -r -a '. ~/Workspace/nix-config github:joker9944/nix-config'
    '';

    home-manager = ''
      complete -c home-manager -r -n '__fish_seen_subcommand_from switch' -l flake -r -a '. ~/Workspace/nix-config github:joker9944/nix-config'
      complete -c home-manager -r -n '__fish_seen_subcommand_from news' -l flake -r -a '. ~/Workspace/nix-config github:joker9944/nix-config'
    '';
  };
}
