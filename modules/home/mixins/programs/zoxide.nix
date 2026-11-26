{ mkMixinModule, ... }:
mkMixinModule "zoxide" {
  programs.zoxide = {
    enable = true;
    options = [
      "--cmd"
      "cd"
    ];
  };
}
