{ custom, ... }:
custom.lib.mkDefaultModule { dir = ./.; } {
  config.programs = {
    waybar.enable = false;
    ashell.enable = false;
    yab.enable = true;
  };
}
