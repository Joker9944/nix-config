{ flake, ... }:
{ lib, ... }:
let
  inherit (flake.lib.hyprland) mkLuaCall;
  inherit (lib.generators) mkLuaInline toLua;

  monitor = {
    output = "eDP-1";
    mode = "3840x2160@60.00Hz";
    position = "0x0";
    scale = 2;
  };

  mkMonitorCall = spec: mkLuaInline "function() hl.monitor(${toLua { multiline = false; } spec}) end";
in
{
  programs._1password.gitSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFcft6944G+ygfWr5wT50TJUQ5f0dAKAr6H4QKSEAsUV";

  mixins.services.wayvnc.enable = true;

  # Hyprland
  wayland.windowManager.hyprland.settings = {
    monitor = [ monitor ];

    # logind leaves a docked lid close alone (HandleLidSwitchDocked = ignore), so
    # the internal panel has to be taken down here. Disabling it migrates its
    # workspaces to the external monitor and back.
    bind = [
      (mkLuaCall [
        "switch:on:Lid Switch"
        (mkMonitorCall {
          inherit (monitor) output;
          disabled = true;
        })
        {
          description = "disable the internal panel on lid close";
          locked = true;
        }
      ])
      (mkLuaCall [
        "switch:off:Lid Switch"
        (mkMonitorCall monitor)
        {
          description = "restore the internal panel on lid open";
          locked = true;
        }
      ])
    ];
  };
}
