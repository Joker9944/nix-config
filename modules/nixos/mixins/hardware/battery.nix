{ mkMixinModule, ... }:
_:
mkMixinModule "battery" {
  # Lid close suspends and escalates to hibernate once the battery is estimated
  # to run low; the countdown starts at unplug, so a lid close on AC only
  # suspends. Resume comes from systemd's HibernateLocation EFI variable, which
  # is why the swapfile-on-LUKS layout needs no boot.resumeDevice.
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  systemd.sleep.settings.Sleep.HibernateOnACPower = false;

  services = {
    # Read by the home tree: the yas battery module is an AstalBattery (UPower)
    # client, and that client is constructed whether or not the module renders.
    upower = {
      enable = true;
      criticalPowerAction = "Hibernate";
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
