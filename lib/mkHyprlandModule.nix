/**
  Create a module that is conditionally enabled when Hyprland is enabled.
  Shorthand for wrapping a module with `mkIf config.windowManager.hyprland.custom.enable`.

  # Type

  ```
  mkHyprlandModule :: config -> module -> module
  ```

  # Example

  ```nix
  mkHyprlandModule config {
    wayland.windowManager.hyprland.settings.bind = [ "SUPER, Return, exec, kitty" ];
  }
  ```
*/
{ lib, self, ... }:
config: self.mkConditionalModule (lib.mkIf config.windowManager.hyprland.custom.enable)
