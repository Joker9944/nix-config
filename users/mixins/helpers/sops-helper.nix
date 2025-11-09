{ lib, config, ... }:
{
  options.mixins.helpers.sops =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "nix helper mixin";
    };

  config.custom.command-collection.branches.sops =
    let
      cfg = config.mixins.helpers.sops;
    in
    lib.mkIf cfg.enable {
      help = "encrypt and decrypt files with sops";

      leafs =
        let
          mkSopsLeaf = method: {
            help = "${method} file in place";

            switches = [
              {
                name = "file";
                type = "Annotated[Path, typer.Argument(exists=True, readable=True, writable=True)]";
              }
              {
                name = "indent";
                type = "Annotated[int, typer.Option()] = 2";
              }
            ];

            code = ''
              subprocess.run(["sops", "--indent", str(indent), "--${method}", "--in-place", file])
            '';
          };
        in
        lib.pipe
          [
            "encrypt"
            "decrypt"
          ]
          [
            (lib.map (method: {
              name = method;
              value = mkSopsLeaf method;
            }))
            lib.listToAttrs
          ];
    };
}
