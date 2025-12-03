{ custom, ... }:
{
  imports = custom.lib.ls.lookup {
    dir = ./.;
    exclude = [ ./default.nix ];
  };
}
