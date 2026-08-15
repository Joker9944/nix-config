{ libUtil, ... }@args:
libUtil.mkLibNamespace {
  context = ./.;
  inherit args;
}
