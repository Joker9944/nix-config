''
  decoration {
    box-shadow: 0 3px 12px 1px rgba(0, 0, 0, 0.7), 0 0 0 1px mix(white,@window_bg_color,0.9);
  }

  decoration:backdrop {
    box-shadow: 0 3px 12px 1px transparent, 0 2px 6px 2px rgba(0, 0, 0, 0.4), 0 0 0 1px mix(white,@window_bg_color,0.95);
  }

  .tiled decoration, .tiled-top decoration, .tiled-bottom decoration, .tiled-right decoration, .tiled-left decoration {
    box-shadow: 0 0 0 1px mix(white,@window_bg_color,0.95), 0 0 0 20px transparent;
  }

  messagedialog.csd decoration, .csd.popup decoration, .maximized .csd.popup decoration {
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.8), 0 0 0 1px alpha(mix(white,@window_bg_color,0.9),0.9);
  }

  tooltip.csd decoration {
    box-shadow: none;
  }

  .maximized decoration, .fullscreen decoration {
    border-radius: 0;
    box-shadow: none;
  }

  .ssd decoration {
    box-shadow: 0 0 0 1px mix(white,@window_bg_color,0.9);
  }

  .ssd decoration:backdrop {
    box-shadow: 0 0 0 1px mix(white,@window_bg_color,0.95);
  }

  .ssd.maximized decoration, .ssd.maximized decoration:backdrop {
    box-shadow: none;
  }

  .solid-csd decoration {
    box-shadow: inset 0 0 0 5px alpha(currentColor,0.5), inset 0 0 0 4px @header_bg_color, inset 0 0 0 1px alpha(currentColor,0.5);
  }

  .solid-csd decoration:backdrop {
    box-shadow: inset 0 0 0 3px @window_bg_color;
  }
''
