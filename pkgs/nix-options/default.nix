{ pkgs, inputs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;

  hmOptionsJson = "${
    inputs.home-manager.packages.${system}.docs-json
  }/share/doc/home-manager/options.json";

  nixosOptions =
    (import "${inputs.nixpkgs}/nixos/lib/eval-config.nix" {
      inherit system;
      modules = [ ];
    }).config.system.build.manual.optionsJSON;
  nixosOptionsJson = "${nixosOptions}/share/doc/nixos/options.json";

  mkOptionsTool =
    { name, optionsJson }:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ pkgs.jq ];
      text = ''
        JSON="${optionsJson}"
      ''
      + builtins.readFile ./files/nix-options.sh;
    };
in
{
  hm-options = mkOptionsTool {
    name = "hm-options";
    optionsJson = hmOptionsJson;
  };

  nixos-options = mkOptionsTool {
    name = "nixos-options";
    optionsJson = nixosOptionsJson;
  };
}
