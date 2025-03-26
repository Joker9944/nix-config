{ config, pkgs, ...}:

with pkgs; let
  mkdirBin = "${ coreutils }/bin/mkdir";
  oidcAddBin = "${ oidc-agent }/bin/oidc-add";
  rcloneBin = "${ rclone }/bin/rclone";
  fusermountBin = "${ fuse }/bin/fusermount";
in {
  home.packages = with pkgs; [ rclone ];

  services.oidc-agent.enable = true;

  xdg.configFile."rclone/owncloud.conf".text = ''
    [owncloud]
    type = webdav
    url = https://cloud.vonarx.online/dav/
    vendor = owncloud
    bearer_token_command = oidc-token owncloud
  '';

  sops.secrets."oidc-agent/owncloud/key".path = "%r/oidc-agent/owncloud_key.txt";

  programs.bash.shellAliases.oidc-gen-owncloud = "oidc-gen --pub --issuer=https://idm.vonarx.online/oauth2/openid/owncloud --client-id=owncloud --redirect-uri=http://localhost:12345 --scope=\"openid profile email groups offline_access\" --pw-file=\"$XDG_RUNTIME_DIR/oidc-agent/owncloud_key.txt\" owncloud";

  systemd.user = {
    services.rclone-mount-owncloud-file-joker9944 = {
      
      Unit = {
        Description = "Joker9944's ownCloud Files rclone Mount";
        After = [ "network.target" "oidc-agent.service" ];
        Requires = "oidc-agent.service";
        Wants = "network-online.target";
      };

      Service = {
        Type = "notify";
        EnvironmentFile = "%t/oidc-agent/oidc-agent.env";

        ExecStartPre = [
          "${ mkdirBin } --parents \"%h/.local/mount/ownCloud\""
          "${ oidcAddBin } --pw-file=\"%t/oidc-agent/owncloud_key.txt\" owncloud"
        ];
        ExecStart = "${ rcloneBin } --config=\"${ config.xdg.configHome }/rclone/owncloud.conf\" --vfs-cache-mode=writes --no-checksum mount \"owncloud:files/joker9944\" \"%h/.local/mount/ownCloud\"";
        ExecStop = "${ fusermountBin } -u \"%h/.local/mount/ownCloud\"";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };

    };
  };
}
