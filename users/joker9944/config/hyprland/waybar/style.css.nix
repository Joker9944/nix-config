{ config, ... }:
with config.windowManager.hyprland.custom.style;
''
  window#waybar {
    background-color: ${pallet.background.normal.rgba opacity.active};
    font-family: 'Symbols Nerd Font', inherit;
  }

  /* general styles */

  #workspaces, #clock, #cpu-group, #gpu-group, #memory-group, #disk-group, #network-group, #volume-group, #battery-group {
    font-weight: bold;
    padding: 0 3px;
    margin: 0 5px;
  }

  button {
    font-weight: bold;
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

  #custom-cpu-label, #custom-gpu-label, #custom-memory-label, #custom-disk-label, #custom-network-label, #custom-volume-label, #custom-battery-label {
    padding-right: 3px;
    margin-right: 1px;
  }

  #cpu, #custom-gpu, #memory, #disk, #network, #wireplumber, #battery {
    font-weight: normal;
    padding-left: 3px;
    margin-left: 1px;
    font-family: monospace;
  }

  #network {
    font-size: 70%;
  }
''
