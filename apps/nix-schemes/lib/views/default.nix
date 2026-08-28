/**
  Views onto a palette. Each takes the 24-slot palette a scheme is built from and returns
  one way of naming it; `mkScheme` computes all of them, so a consumer never has to ask
  whether one is there.
*/
{ libUtil, ... }@args:
libUtil.mkLibNamespace {
  context = ./.;
  inherit args;
}
