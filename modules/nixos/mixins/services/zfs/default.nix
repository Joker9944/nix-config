{ mkMixinModule, inputs, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
mkMixinModule "zfs" {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  boot = {
    supportedFilesystems.zfs = true;
    # Do not force-import pools that weren't cleanly exported — the safer 26.11 default.
    zfs.forceImportRoot = false;
  };

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets."zed/gotify-token".sopsFile = ./secrets/zed.yaml;
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = lib.mkDefault true;

    zed.settings = {
      ZED_GOTIFY_URL = "https://gotify.vonarx.online";
      # zed.rc is sourced by the zedlet, so this substitution runs there and the
      # token never reaches the world-readable /etc copy. Absolute cat: zed
      # hands its children a hardcoded _PATH_STDPATH, and the PATH this file
      # sets is not in effect until the line above it has been read.
      ZED_GOTIFY_APPTOKEN = "$(${lib.getExe' pkgs.coreutils "cat"} ${
        config.sops.secrets."zed/gotify-token".path
      })";
      # Without this a clean scrub sends nothing, so silence cannot be told
      # apart from a broken zed.
      ZED_NOTIFY_VERBOSE = true;
      # zed_rate_limit falls back to an empty interval when unset, which errors
      # out of its comparison and disables rate limiting altogether.
      ZED_NOTIFY_INTERVAL_SECS = 3600;
    };
  };
}
