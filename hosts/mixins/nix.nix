{ lib, config, ... }:
{
  options.mixins.nix =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "nix config mixin";
    };

  config =
    let
      cfg = config.mixins.nix;
    in
    lib.mkIf cfg.enable {
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        substituters = lib.toList "https://nix-community.cachix.org";
        trusted-public-keys = lib.toList "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="; # cSpell:disable-line
      };
    };
}
