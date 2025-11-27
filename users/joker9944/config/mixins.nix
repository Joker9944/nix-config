{
  mixins = {
    fonts.enable = true;

    helpers = {
      enable = true;
      nix.enable = true;
      sops.enable = true;
    };

    programs = {
      _1password.enable = true;
      bash.enable = true;
      discord.enable = true;
      firefox.enable = true;
      gnome-text-editor.enable = true;
      jetbrains.enable = true;
      jupyter.enable = true;
      loupe.enable = true;
      nextcloud-client.enable = true;
      papers.enable = true;
      spotify.enable = true;
      telegram.enable = true;
      vscode.enable = true;
      wxmaxima.enable = true;
      xournalpp.enable = true;
      zoom.enable = true;
    };

    pwas = {
      audiobookshelf.enable = true;
      jellyfin.enable = true;
    };
  };
}
