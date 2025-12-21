{
  lib,
  appimageTools,
  fetchurl,
  ...
}:
let
  pname = "freelens";
  version = "1.7.0";

  src = fetchurl {
    url = "https://github.com/freelensapp/${pname}/releases/download/v${version}/Freelens-${version}-linux-amd64.AppImage";
    sha256 = "sha256-VeWTfJf66Cq4ZyR/mO0kzm8wD+Auo1MZvXPYC1Bbf7U=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/${pname}.png $out/share/icons/hicolor/512x512/apps/${pname}.png
    substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${pname}'
  '';

  meta =
    let
      inherit (lib) licenses;
    in
    {
      description = "Free IDE for Kubernetes";
      homepage = "https://freelens.app/";
      license = licenses.mit;
      mainProgram = "freelens";
    };
}
