{ flake, ... }:
{
  File-MimeInfo = _: prev: {
    inherit (flake.packages.${prev.stdenv.hostPlatform.system}) File-MimeInfo;
  };

  freelens = _: prev: {
    inherit (flake.packages.${prev.stdenv.hostPlatform.system}) freelens;
  };

  openldap-fix = _: prev: {
    openldap =
      builtins.warn
        ''
          HACK(serene-franklin): openldap test runs are broken on nixpkgs
          https://github.com/NixOS/nixpkgs/issues/513245
        ''
        (
          prev.openldap.overrideAttrs (_: {
            doCheck = !prev.stdenv.hostPlatform.isi686;
          })
        );
  };
}
