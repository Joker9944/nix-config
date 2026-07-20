{ mkMixinModule, ... }:
mkMixinModule "atuin" {
  programs.atuin = {
    enable = true;

    daemon.enable = true;

    settings = {
      filter_mode_shell_up_key_binding = "session";
    };
  };
}
