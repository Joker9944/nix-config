{
  pname,
  python3Packages,
  writeScript,
  code,
  ...
}:
python3Packages.buildPythonApplication {
  inherit pname;
  version = "1.0.0";
  pyproject = false; # cSpell:ignore pyproject dontUnpack
  dontUnpack = true;

  src = writeScript "${pname}.py" code;

  dependencies = with python3Packages; [ typer ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${pname}
  '';

  meta.mainProgram = pname;
}
