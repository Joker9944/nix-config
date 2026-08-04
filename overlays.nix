{ flake, ... }:
{
  downlords-faf-client = _: prev: {
    inherit (flake.packages.${prev.stdenv.hostPlatform.system}) downlords-faf-client;
  };

  faf-game-launcher = _: prev: {
    inherit (flake.packages.${prev.stdenv.hostPlatform.system}) faf-game-launcher;
  };

  File-MimeInfo = _: prev: {
    inherit (flake.packages.${prev.stdenv.hostPlatform.system}) File-MimeInfo;
  };

  freelens = _: prev: {
    inherit (flake.packages.${prev.stdenv.hostPlatform.system}) freelens;
  };

  eisvogel = _: prev: {
    inherit (flake.packages.${prev.stdenv.hostPlatform.system}) eisvogel;
  };
}
