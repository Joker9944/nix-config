{ cfg, ... }:
let
  inherit (cfg.style) pallet opacity;
in
''
  #window {
    background-color: ${pallet.background.normal.rgba opacity.active};
  }

  #input {
    background-color: ${pallet.background.dark.rgba opacity.active};
  }
''
