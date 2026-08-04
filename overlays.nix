{ flake, ... }:
{
  File-MimeInfo = _: prev: {
    inherit (flake.packages.${prev.stdenv.hostPlatform.system}) File-MimeInfo;
  };

  eisvogel = _: prev: {
    inherit (flake.packages.${prev.stdenv.hostPlatform.system}) eisvogel;
  };
}
