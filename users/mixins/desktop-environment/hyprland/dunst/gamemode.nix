{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.gamemode.config.custom =
    let
      writeScript =
        script:
        lib.pipe script [
          (
            script:
            pkgs.writeShellApplication {
              name = lib.removeSuffix ".sh" script;

              text = lib.readFile (lib.path.append ./files script);

              runtimeInputs = with pkgs; [
                config.services.dunst.package
                coreutils
              ];

              # Options are set in the script itself
              bashOptions = [ ];
            }
          )
          lib.getExe
        ];
    in
    {
      start = writeScript "mute-notifications.sh";
      end = writeScript "unmute-notifications.sh";
    };
}
