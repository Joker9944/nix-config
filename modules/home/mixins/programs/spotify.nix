{
  mkMixinModule,
  inputs,
  ...
}:
{
  config,
  pkgs-unstable,
  ...
}:
mkMixinModule "spotify" {
  imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];

  programs.spicetify = {
    enable = true;

    spotifyPackage = pkgs-unstable.spotify;
    spicetifyPackage = pkgs-unstable.spicetify-cli;
  };

  schemes.spicetify.enable = true;

  wayland.windowManager.hyprland.settings =
    let
      cfg = config.mixins.desktopEnvironment.hyprland;
    in
    cfg.mkAppWorkspace {
      id = "spotify";
      class = "Spotify";
      launch = cfg.mkAppEntryCommand {
        package = config.programs.spicetify.spotifyPackage;
      };
    };
}
