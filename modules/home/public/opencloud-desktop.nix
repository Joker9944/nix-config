_:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.opencloud-desktop;
in
{
  meta.maintainers = with lib.hm.maintainers; [
    joker9944
  ];

  options.services.opencloud-desktop =
    let
      inherit (lib) mkEnableOption mkPackageOption;
    in
    {
      enable = mkEnableOption "OpenCloud Desktop sync client";

      package = mkPackageOption pkgs "opencloud-desktop" { };
    };

  config =
    let
      # the package ships no meta.mainProgram, and its executable is not named after it
      opencloud = lib.getExe' cfg.package "opencloud";
    in
    lib.mkIf cfg.enable {
      assertions = [
        (lib.hm.assertions.assertPlatform "services.opencloud-desktop" pkgs lib.platforms.linux)
      ];

      systemd.user.services.opencloud-desktop = {
        Unit = {
          Description = "OpenCloud Desktop sync client";
          After = lib.toList "graphical-session.target";
          PartOf = lib.toList "graphical-session.target";
        };

        Service = {
          Environment = [ "PATH=${config.home.profileDirectory}/bin" ];
          ExecStart = opencloud;
          ExecStop = "${opencloud} --quit";
          KillMode = "process";
          Restart = "on-failure";
          RestartSec = "5s";
        };

        Install.WantedBy = lib.toList "graphical-session.target";
      };
    };
}
