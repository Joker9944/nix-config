{ config, ... }:
let
  xserverDisplayManagerCfg = config.services.xserver.displayManager;
in
{
  services = {
    displayManager = {
      ly = {
        enable = true;
      };
    };
  };
}
