{ config, ... }:
# TODO make a nix to css lib
let
  inherit (config.windowManager.hyprland.custom.style) pallet opacity;
in
''
  window#waybar {
    background-color: ${pallet.background.normal.rgba opacity.active};
    font-family: 'Symbols Nerd Font', inherit;
  }

  /* general styles */

  #workspaces, #clock, #cpu, #custom-gpu, #memory, #disk, #network-group, #wireplumber, #upower {
    padding: 0 3px;
    margin: 0 5px;
  }

  #workspaces, #clock {
    font-weight: bold;
  }

  button {
    padding: 0 3px;
    margin: 0 1px;
  }

  button:hover {
    background: inherit;
    box-shadow: inset 0 -3px @theme_selected_bg_color;
  }

  button.active {
    background-color: @theme_selected_bg_color;
    box-shadow: none;
  }

  button.urgent {
    background-color: @error_color;
  }

  #workspaces button.special {
    font-weight: normal;
    font-size: 120%;
  }
''
