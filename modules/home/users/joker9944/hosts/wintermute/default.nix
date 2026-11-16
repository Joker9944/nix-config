{ flake, ... }:
{ lib, ... }:
let
  inherit (flake.lib.hyprland) mkLuaCall;
  inherit (lib.generators) mkLuaInline;

  monitor = {
    output = "eDP-1";
    mode = "3840x2160@60.00Hz";
    position = "0x0";
    scale = 2;
  };
in
{
  programs._1password.gitSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFcft6944G+ygfWr5wT50TJUQ5f0dAKAr6H4QKSEAsUV";

  mixins.services.wayvnc.enable = true;

  # Hyprland
  wayland.windowManager.hyprland.settings = {
    monitor = [ monitor ];

    # logind leaves a docked lid close alone (HandleLidSwitchDocked = ignore), so
    # the internal panel has to be taken down here. Undocked, logind suspends and
    # the panel must stay up: the lid-open event is lost across a resume.
    bind = [
      (mkLuaCall [
        "switch:on:Lid Switch"
        (mkLuaInline ''
          function()
            for _, m in ipairs(hl.get_monitors()) do
              if m.name ~= "${monitor.output}" then
                hl.monitor({ output = "${monitor.output}", disabled = true })
                return
              end
            end
          end
        '')
        {
          description = "disable the internal panel on lid close when docked";
          locked = true;
        }
      ])
      # hl.monitor cannot re-enable a disabled output; a reload can.
      (mkLuaCall [
        "switch:off:Lid Switch"
        (mkLuaInline "hl.dsp.reload_config()")
        {
          description = "restore the internal panel on lid open";
          locked = true;
        }
      ])
    ];
  };
}
