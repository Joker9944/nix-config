{ mkMixinModule, inputs, ... }:
{ config, ... }:
let
  cacheUser = "nix-cache";
  harmoniaSocket = "/run/harmonia.sock";
in
mkMixinModule "nixCache" {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets."nix-cache/sign-key".sopsFile = ./secrets/nix-cache.yaml;
  };

  services = {
    harmonia.cache = {
      enable = true;
      signKeyPaths = [ config.sops.secrets."nix-cache/sign-key".path ];
      settings = {
        bind = "unix:${harmoniaSocket}";
        # Behind cache.nixos.org (40): mother holds whole closures, so a higher
        # priority would route every download through it.
        priority = 50;
      };
    };

    tailscale.serve = {
      enable = true;
      services.nix-cache.endpoints = {
        # https:// would also make the backend speak TLS, and set-config only
        # accepts tls-terminated-tcp with a unix socket target.
        "tcp:443" = "tls-terminated-tcp://unix:${harmoniaSocket}";
        "tcp:22" = "tcp://localhost:22";
      };
    };
  };

  # Untrusted on purpose: the daemon only accepts paths carrying a signature
  # from trusted-public-keys, so a leaked CI credential cannot reach root.
  users = {
    users.${cacheUser} = {
      isSystemUser = true;
      group = cacheUser;
      useDefaultShell = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG+cz3+ZCHJ6ze13bDhTMPQCk6KFxdBabd55+fgFYN/J nix-config-ci" # cSpell:disable-line
      ];
    };
    groups.${cacheUser} = { };
  };

  nix.settings.trusted-public-keys = [
    "nix-config-ci-1:y+2TMAC/gi35HA91ALCwPsZyMn95UvpNJuxbbJOpptE=" # cSpell:disable-line
  ];

  # Each pushed closure is a generation here; nix.gc's --delete-older-than
  # recurses into per-user profiles, so that is the retention policy.
  systemd.tmpfiles.rules = [
    "d /nix/var/nix/profiles/per-user/${cacheUser} 0755 ${cacheUser} ${cacheUser} -"
  ];
}
