{
  config,
  lib,
  ...
}: {
  options.services.udev.dualsenseFix = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable DualSense trackpad fix.
      '';
    };
  };

  config = {
    services.udev.extraRules = ''
      # Disable DualSense controller touchpad being recognized as a trackpad
      ACTION=="add|change", KERNEL=="event[0-9]*", ATTRS{name}=="*Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    '';
  };
}
