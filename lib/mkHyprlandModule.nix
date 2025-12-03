{ lib, self, ... }:
config: self.mkConditionalModule (lib.mkIf config.windowManager.hyprland.custom.enable)
