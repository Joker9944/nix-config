{ mkMixinModule, ... }:
mkMixinModule "zfs" {
  boot = {
    supportedFilesystems.zfs = true;
    # Do not force-import pools that weren't cleanly exported — the safer 26.11 default.
    zfs.forceImportRoot = false;
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
    # Host sets ZED_EMAIL_* under zed.settings for scrub/degraded alerts.
    zed.settings = { };
  };
}
