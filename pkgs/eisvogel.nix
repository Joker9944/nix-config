{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "eisvogel";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "Wandmalfarbe"; # cSpell:ignore Wandmalfarbe
    repo = "pandoc-latex-template";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0tz/I4eEVJYFBHWvxRPg5ZRsPERGCGyTqItphp3wies=";
  };

  configurePhase = ''
    runHook preConfigure

    chmod +x tools/release.sh
    patchShebangs tools/release.sh

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    ./tools/release.sh

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir --parents $out/share/eisvogel/templates
    cp dist/eisvogel.latex $out/share/eisvogel/templates
    cp dist/eisvogel.beamer $out/share/eisvogel/templates

    runHook postInstall
  '';

  meta = {
    description = "A pandoc LaTeX template to convert markdown files to PDF or LaTeX.";
    homepage = "https://github.com/Wandmalfarbe/pandoc-latex-template";
    license = lib.licenses.bsd3;
  };
})
