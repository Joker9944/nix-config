{
  breeze,
  runCommand,
  python3,
  resvg,
}:
runCommand "cursor-identity"
  {
    nativeBuildInputs = [
      python3
      resvg
    ];
  }
  ''
    python3 ${./identity.py} \
      ${breeze}/cursors/Breeze/src/svg \
      ${../../vendor/cursors/breeze/svg}
    touch $out
  ''
