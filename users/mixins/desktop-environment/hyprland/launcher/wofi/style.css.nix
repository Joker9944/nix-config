{ cfg, ... }:
let
  inherit (cfg.style) scheme opacity;
in
''
  #window {
    background-color: ${scheme.named.background.normal.rgba opacity.active};
  }

  #input {
    background-color: ${scheme.named.background.dark.rgba opacity.active};
  }
''
