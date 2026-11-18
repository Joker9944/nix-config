_:
{ lib, ... }:
{
  custom.greeting = {
    modules = lib.mkAfter [ "zpool" ];
    diskCount = 3;
    color = "green";
    taglines = [ "INTERFACE 2037 READY FOR INQUIRY" ];
    art = ''
      ╔═══════════════════╗
      ║ MU/TH/UR 6000     ║
      ║ ───────────────── ║
      ║ > _               ║
      ╚═══════════════════╝
    '';
  };
}
