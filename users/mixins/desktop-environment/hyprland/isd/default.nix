{ custom, ... }:
{
  imports = custom.lib.ls {
    dir = ./.;
    exclude = [ ./default.nix ];
  };
}
