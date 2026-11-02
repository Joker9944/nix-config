{ mkMixinModule, ... }:
mkMixinModule "battery" {
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";

  services = {
    # Enabled for readout only.
    upower = {
      enable = true;
      criticalPowerAction = "Ignore";
      allowRiskyCriticalPowerAction = true;
    };

    # Chosen over power-profiles-daemon; the two cannot coexist.
    tlp = {
      enable = true;

      settings = {
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        PLATFORM_PROFILE_ON_AC = "balanced";
        PLATFORM_PROFILE_ON_BAT = "low-power";
      };
    };
  };
}
