{ flake }:
{ lib, ... }:
{
  imports =
    lib.pipe
      {
        dir = ./.;
        exclude = [ ./default.nix ];
      }
      [
        flake.lib.ls
        (lib.map (path: lib.modules.importApply path { inherit flake; }))
      ];

  options.programs.regreet =
    let
      inherit (lib) mkOption types;
    in
    {
      compositor = mkOption {
        type = types.enum [
          "cage"
          "hyprland"
        ];
        default = "cage";
        description = ''
          Which compositor should be used to run regreet.
        '';
      };
    };
}
