{ mkHyprlandModule, ... }:
_:
mkHyprlandModule {
  programs.numbat = {
    enable = true;

    settings = {
      prompt = "> ";
    };
  };
}
