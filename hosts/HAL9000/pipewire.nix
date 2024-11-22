{ config, pkgs, ... }:

{
  services.pipewire.wireplumber.extraConfig = {
    "alsa-rename" = {
      "monitor.alsa.rules" = [{
        matches = [{
          "device.name" = "alsa_card.pci-0000_0b_00.4";
        }];
        actions = {
          update-props = {
            "node.description" = "Edifier R1280DB";
          };
        };
      }];
    };
    "alsa-disable" = {
      "monitor.alsa.rules" = [{
        matches = [{
          "device.name" = "alsa_card.pci-0000_09_00.1";
        }];
        actions = {
          update-props = {
            "device.disabled" = true;
          };
        };
      }];
    };
  };
}
