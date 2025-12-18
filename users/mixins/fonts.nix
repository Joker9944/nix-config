{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.fonts =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "fonts config mixin";
    };

  config =
    let
      cfg = config.mixins.fonts;
    in
    lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        lato
        roboto
        noto-fonts-color-emoji
      ];

      fonts.fontconfig = {
        enable = true;

        defaultFonts = {
          monospace = [ "JetBrainsMono Nerd Font Mono" ];
          sansSerif = [
            "Lato"
            "Roboto"
          ];
          emoji = [
            "Noto Color Emoji"
          ];
        };
      };
    };
}
