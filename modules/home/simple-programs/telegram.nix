{
  pkgs,
  config,
  utility,
  ...
}:
utility.custom.mkSimpleProgramHomeModule {
  inherit pkgs config;
  name = "telegram";
  pkgName = "telegram-desktop";
}
