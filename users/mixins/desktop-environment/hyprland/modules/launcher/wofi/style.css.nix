{ cfg, ... }:
let
  inherit (cfg.style) scheme opacity;
in
''
  #window {
    background-color: rgba(${scheme.named.background.normal.rgba opacity.active});
  }

  #input {
    background-color: rgba(${scheme.named.background.dark.rgba opacity.active});
  }
''
