{
  pkgs,
  config,
  utility,
  ...
}:
utility.custom.mkSimpleProgramHomeModule {
  inherit pkgs config;
  name = "teamspeak-client";
  packageName = "teamspeak3";
}
