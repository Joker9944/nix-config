_:
{
  inputs,
  config,
  ...
}:
{
  imports = [ inputs.nix-schemes.nixosModules.default ];

  config =
    let
      cfg = config.custom.theme;
    in
    {
      schemes.regreet = {
        inherit (cfg.gtk) accent;

        accents.mode = if cfg.gtk.uniformAccents then "uniform" else "palette";
      };
    };
}
