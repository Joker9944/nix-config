{
  lib,
  perlPackages,
  fetchgit,
  ...
}:
let
  pname = "File-MimeInfo";
  version = "0.37";
in
perlPackages.buildPerlPackage {
  inherit pname version;

  src = fetchgit {
    url = "https://codeberg.org/michielb/${pname}.git";
    rev = version;
    hash = "sha256-0zZDoB0anyIa9QjblFhikfqQlKW98RkOW4ubNP+0+zs=";
  };

  buildInputs = with perlPackages; [
    EncodeLocale
    FileBaseDir
    FileDesktopEntry
  ];

  meta =
    let
      inherit (lib) licenses;
    in
    {
      description = "Perl module for determining file types using the freedesktop.org shared mime-info database.";
      homepage = "https://github.com/mbeijen/File-MimeInfo";
      license = licenses.artistic2;
      mainProgram = "mimeopen";
    };
}
