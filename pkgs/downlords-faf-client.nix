{
  lib,
  stdenv,
  makeWrapper,
  copyDesktopItems,
  temurin-jre-bin-25,
  javaPackages,
  steam-run-free,
  fetchurl,
  fetchzip,
  makeDesktopItem,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "downlords-faf-client"; # cSpell:ignore downlords
  version = "2026.7.0";

  src =
    let
      escapedVersion = lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version;
    in
    fetchzip {
      url = "https://github.com/FAForever/${finalAttrs.pname}/releases/download/v${finalAttrs.version}/faf_unix_${escapedVersion}.tar.gz";
      sha256 = "sha256-2/NnUiKDziU9RNQXzDMR9PBL9nw5gGtPicasUohusvs=";
    };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  # cSpell:ignore Dnative Djava
  # cSpell:words vmoptions
  installPhase = ''
    mkdir -p $out/bin $out/share/${finalAttrs.pname}
    cp -r $src/* $out/share/${finalAttrs.pname}
    cp -r $src/.install4j $out/share/${finalAttrs.pname}

    substituteInPlace $out/share/${finalAttrs.pname}/faf-client.vmoptions \
      --replace "-DnativeDir=natives" "-DnativeDir=$out/share/${finalAttrs.pname}/natives" \
      --replace "-Djava.library.path=." "-Djava.library.path=${javaPackages.openjfx25}/modules_libs/javafx.media"

    makeWrapper ${lib.getExe steam-run-free} $out/bin/${finalAttrs.pname} \
      --set INSTALL4J_JAVA_HOME ${temurin-jre-bin-25} \
      --add-flags $out/share/${finalAttrs.pname}/faf-client
  '';

  # cSpell:ignore faforever
  desktopItems =
    let
      fafIconPath = fetchurl {
        url = "https://www.faforever.com/images/faf-logo.png";
        sha256 = "sha256-uyg0gIqJ78JOoeb/XKNdCaDyIPRQLLR2ifyDguvqGn0=";
      };
      fafDesktopItem = makeDesktopItem {
        name = "com.faforever.faf-linux";
        desktopName = "Forged Alliance Forever";
        comment = finalAttrs.meta.description;
        exec = finalAttrs.pname;
        icon = fafIconPath;
        startupWMClass = "com.faforever.client.FafClientApplication";
        categories = [
          "Network"
          "Game"
        ];
        keywords = [ "faf" ];
      };
    in
    [ fafDesktopItem ];

  meta = {
    description = "Lobby client for Supreme Commander: Forged Alliance (faf-linux)";
    homepage = "https://github.com/FAForever/downlords-faf-client";
    license = lib.licenses.mit;
    maintainers = {
      name = "Felix von Arx";
      email = "github@shroud.mozmail.com";
      github = "Joker9944";
      githubId = 9194199;
    };
  };
})
