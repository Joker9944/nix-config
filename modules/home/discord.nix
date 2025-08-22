{
  pkgs,
  config,
  utility,
  ...
}:
utility.custom.mkSimpleProgramHomeModule {
  inherit pkgs config;
  name = "discord";
}
