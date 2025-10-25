{
  lib,
  python3Packages,
  writeScript,
  code,
  ...
}:
python3Packages.buildPythonApplication {
  pname = "command-collection-helper";
  version = "1.0.0";
  pyproject = false; # cSpell:ignore pyproject dontUnpack
  dontUnpack = true;

  src = writeScript "command-collection-helper.py" (
    lib.concatLines [
      "#!/usr/bin/env python3"
      code
    ]
  );

  dependencies = with python3Packages; [ typer ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/command-collection-helper
  '';

  meta.mainProgram = "command-collection-helper";
}
