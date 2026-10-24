_:
{ pkgs, ... }:
{
  terminal.font = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFontMono-Regular.ttf";

  home-manager = {
    backupFileExtension = "hm-bak";

    config = {
      mixins.programs = {
        bash.enable = true;
        direnv.enable = true;
        eza.enable = true;
        fish.enable = true;
        git.enable = true;
        jupyter.enable = true;
        starship.enable = true;
      };

      programs.git.settings.user = {
        email = "9194199+Joker9944@users.noreply.github.com";
        name = "Joker9944";
      };

      home.stateVersion = "26.05";
    };
  };
}
