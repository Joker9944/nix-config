{ ... }:

{
  fileSystems."/mnt/linux-games" = {
    device = "/dev/disk/by-uuid/abe35444-076d-4e0e-afd1-6d3be2d97d6c";
    fsType = "ext4";
    options = [
      "nosuid"
      "nodev"
      "nofail"
      "rw"
      "exec"
    ];
  };

  fileSystems."/mnt/windows-games" = {
    device = "/dev/disk/by-uuid/529952040F63F024";
    fsType = "ntfs";
    options = [
      "uid=1000"
      "gid=100"
      "umask=000"
      "user"
      "rw"
      "exec"
    ];
  };
}
