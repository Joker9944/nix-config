{ flake, ... }@args:
flake.lib.modules.mkDefaultModule
  {
    dir = ./.;
    inherit args;
  }
  {
    # Lenovo ThinkPad X1 Yoga Gen 4
    # * https://wiki.archlinux.org/title/Lenovo_ThinkPad_X1_Yoga_(Gen_4)

    boot.loader.limine.style.interface.brandingColor = "#0000FF"; # blue

    hardware.bluetooth.enable = true;

    programs.regreet.hyprland.settings.window_rule = [
      {
        match.initial_class = "apps\\.regreet";
        monitor = "eDP-1";
      }
    ];

    services = {
      xserver.xkb.layout = "ch";

      # Enable finger print reader service
      fprintd.enable = false;

      # Supports Linux Vendor Firmware Service (lvfs)
      fwupd.enable = true;

      tailscale = {
        useRoutingFeatures = "client";
        extraSetFlags = [ "--accept-routes" ];
      };

      # Reached through thinkpad_acpi, so not part of the battery mixin.
      tlp.settings = {
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It's perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05";
  }
