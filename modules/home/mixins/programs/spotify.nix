{
  mkMixinModule,
  flake,
  inputs,
  ...
}:
{
  lib,
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
      workspace = "spotify";
    in
    {
      bind =
        let
          inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
          inherit (flake.lib.hyprland) mkLuaCall;
          inherit (lib.generators) mkLuaInline;
        in
        [
          (mkLuaCall [
            "${mods.app} + S"
            (mkLuaInline "hl.dsp.workspace.toggle_special(\"${workspace}\")")
          ])
        ];

      workspace_rule = [
        {
          workspace = "special:${workspace}";
          on_created_empty = "spotify";
        }
      ];

      window_rule = [
        {
          name = "spotify";
          match.class = "Spotify";
          workspace = "special:${workspace}";
        }
      ];
    };
}
