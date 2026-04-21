{ mkDefaultHyprlandModule, ... }:
{
  inputs,
  lib,
  config,
  pkgs,
  custom,
  ...
}:
mkDefaultHyprlandModule { dir = ./.; } {
  imports =
    (with inputs.nix-schemes.homeManagerModules; [
      scheme
      gtk
      librewolf
    ])
    ++ [ inputs.nix-wallust.homeManagerModules.default ];

  options.mixins.desktopEnvironment.hyprland.style =
    let
      inherit (lib) mkOption types;
    in
    {
      theme = mkOption {
        type = types.enum [
          "dracula"
          "uwunicorn"
        ];
        default = "uwunicorn";
        description = ''
          The theme to style hyprland and apps with.
        '';
      };
    };

  config = {
    programs.wallust = {
      enable = true;

      settings = {
        backend = "full";
        color_space = "lchmixed"; # cSpell:ignore lchmixed
        palette = "darkcomp16"; # cSpell:ignore darkcomp16
      };
    };

    mixins.desktopEnvironment.hyprland.style = {
      fonts = {
        interface = {
          name = "Inter";
          package = pkgs.inter;
          size = 10;
        };

        terminal = {
          name = "JetBrainsMono Nerd Font Mono";
          package = pkgs.nerd-fonts.jetbrains-mono;
          size = 10;
        };
      };

      inherit (config.schemes) scheme;

      opacity = {
        active = 0.95;
        inactive = 0.9;
      };

      border = {
        size = 2;

        corners = {
          rounding = 10;
          power = 2.0;
        };
      };
    };

    custom.easyGtk = {
      documentText = {
        name = "Lato";
        package = pkgs.lato;
        size = 12;
      };

      monospaceText = {
        name = "JetBrains Mono";
        package = pkgs.jetbrains-mono;
        size = 10;
      };
    };

    schemes = {
      gtk.enable = true;

      librewolf = {
        enable = true;
        # TODO this is not right, find a way to improve this
        profiles = [ custom.config.username ];
      };
    };
  };
}
