{
  lib,
  perlPackages,
  fetchFromGitHub,
}:
perlPackages.buildPerlPackage rec {
  pname = "File-MimeInfo";
  version = "0.35";

  src = fetchFromGitHub {
    owner = "mbeijen"; # cSpell:ignore mbeijen
    repo = pname;
    rev = version;
    sha256 = "sha256-6xU7S7Wp98rDlXrxi/UXK6h2siS6Fte20S5eTQCWZyw=";
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
