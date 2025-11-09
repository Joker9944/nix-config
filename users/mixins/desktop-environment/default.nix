{ utility, ... }:
{
  imports = utility.custom.ls.lookup {
    dir = ./.;
    exclude = [ ./default.nix ];
  };
}
