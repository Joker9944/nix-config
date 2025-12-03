{ custom, ... }:
{
  imports = custom.lib.ls.lookup {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  mixins.keymap.type = "ch";

  # Lenovo ThinkPad X1 Yoga Gen 4
  # * https://wiki.archlinux.org/title/Lenovo_ThinkPad_X1_Yoga_(Gen_4)

  boot.loader.limine.style.interface.brandingColor = 4; # blue

  services = {
    # Enable finger print reader service
    fprintd.enable = false;

    # Supports Linux Vendor Firmware Service (lvfs)
    fwupd.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05";
}
