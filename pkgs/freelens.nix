# cSpell:words freelens freelensapp setuptools
{
  lib,
  stdenv,

  fetchFromGitHub,

  nodejs,
  pnpm_10,
  python3Packages,
  electron_35,
  ...
}:
let
  pnpm = pnpm_10;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "freelens";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "freelensapp";
    repo = "freelens";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-ORKXzk0HEGtHdKRgXCE6OGsJz17ut+yVLRdzCrHIzS4=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
    python3Packages.setuptools
    electron_35
  ];

  buildPhase = ''
    runHook preBuild
    cd freelens && pnpm build:app:linux
    runHook postBuild
  '';

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    sourceRoot = "${finalAttrs.src.name}/freelens";
    fetcherVersion = 1;
    hash = "sha256-sltt5twiJm3CgrF5LwOyCT4iqf6Ci92pYNW0U6JtvJU=";
  };

  meta = {
    description = "Free IDE for Kubernetes";
    homepage = "https://freelens.app/";
    license = lib.licenses.mit;
    inherit (nodejs.meta) platforms;
  };
})
