{ flake, ... }:
{
  File-MimeInfo = _: prev: {
    inherit (flake.packages.${prev.stdenv.hostPlatform.system}) File-MimeInfo;
  };

  freelens = _: prev: {
    inherit (flake.packages.${prev.stdenv.hostPlatform.system}) freelens;
  };
}
