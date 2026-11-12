{ libUtil, ... }@args:
removeAttrs (libUtil.mkLibNamespace {
  context = ./.;
  inherit args;
}) [ "mkAcceptRules" ]
