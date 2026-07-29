{ mkMixinModule, ... }:
{ lib, ... }:
mkMixinModule "maintenance" {
  nix = {
    # Enable automatic nix store garbage collection
    gc = {
      automatic = lib.mkDefault true;
      persistent = true;
      dates = lib.mkDefault "weekly";
      options = "--delete-older-than 30d";
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
    flake = "github:Joker9944/nix-config";
    dates = lib.mkDefault "*-*-* 04:00:00 UTC"; # 1 hour after GitHub actions nix flake update
    notify.enable = true;
  };

  systemd = {
    slices.anti-hungry.sliceConfig = {
      CPUWeight = 20;
      IOWeight = 20;
      MemoryAccounting = true;
      MemoryHigh = "75%";
      MemorySwapMax = "50%";
    };

    services.nix-daemon.serviceConfig.Slice = "anti-hungry.slice";
  };
}
