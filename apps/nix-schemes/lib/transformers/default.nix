/**
  Collection of scheme transformers.
  Transformers add or modify scheme attributes and can be chained via `scheme.transform`.
*/
{ libUtil, ... }@args:
libUtil.mkLibNamespace {
  context = ./.;
  inherit args;
}
