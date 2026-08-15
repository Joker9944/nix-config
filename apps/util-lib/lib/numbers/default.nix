{ libSelf, ... }@args:
libSelf.mkLibNamespace {
  context = ./.;
  inherit args;
}
