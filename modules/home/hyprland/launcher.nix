{ lib, ... }:
{
  options.windowManager.hyprland.custom.launcher = with lib; {
    mkDmenuCommand = mkOption {
      type = types.functionTo types.str;
      default =
        {
          location ? null,
          search ? true,
          width ? null,
          height ? null,
          x ? null,
          y ? null,
          extraArgs ? [ ],
          ...
        }:
        lib.concatStringsSep " " (
          [ "wofi --dmenu" ]
          ++ lib.optional (location != null) "--location ${location}"
          ++ lib.optional (!search) "--define hide_search=true"
          ++ lib.optional (width != null) "--width ${toString width}"
          ++ lib.optional (height != null) "--height ${toString height}"
          ++ lib.optional (x != null) "--xoffset ${toString x}"
          ++ lib.optional (y != null) "--yoffset ${toString y}"
          ++ extraArgs
        );
      description = ''
        Function to generate a dmenu command.
      '';
    };
  };
}
