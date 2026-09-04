{ pkgs, ... }:
{
  tidy-branches = pkgs.writeShellApplication {
    name = "tidy-branches";

    runtimeInputs = [ pkgs.git ];

    text = builtins.readFile ./files/tidy-branches.sh;

    meta.description = "Deletes local branches whose work is already in the default branch";
  };
}
