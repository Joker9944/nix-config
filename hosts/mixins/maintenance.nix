{
  lib,
  options,
  config,
  ...
}:
{
  options.mixins.services.maintenance =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "maintenance config mixin";
      flake = options.system.autoUpgrade.flake // {
        default = "github:Joker9944/nix-config";
      };
    };

  config =
    let
      cfg = config.mixins.services.maintenance;
    in
    lib.mkIf cfg.enable {
      nix = {
        # Enable automatic nix store garbage collection
        gc = {
          automatic = lib.mkDefault true;
          persistent = true;
          dates = lib.mkDefault "weekly";
        };

        # Enable automatic nix store optimization
        optimise = {
          automatic = lib.mkDefault true;
          dates = lib.mkDefault [ "weekly" ];
        };
      };

      # Enable automatic upgrades
      system.autoUpgrade = {
        enable = lib.mkDefault true;
        persistent = true;
        inherit (cfg) flake;
        dates = lib.mkDefault "*-*-* 04:00:00 UTC"; # 1 hour after GitHub actions nix flake update
        notify.enable = true;
      };
    };
}
