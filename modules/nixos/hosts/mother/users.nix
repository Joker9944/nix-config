_:
{ lib, ... }:
{
  # Names for the numeric owners on chronos/media-data, which predate this
  # machine: the uids the cluster's media apps run as, and 6000 as their shared
  # group. Nothing here grants access — NFSv4 with sec=sys maps by number — it
  # keeps `ls -l` readable and keeps NixOS from allocating one of these uids to
  # an unrelated service. k8s-config owns the assignment.
  users = {
    groups.media.gid = 6000;

    users = {
      joker9944.extraGroups = [ "media" ];
    }
    //
      lib.mapAttrs
        (_: uid: {
          inherit uid;
          isSystemUser = true;
          group = "media";
        })
        {
          qbittorrent = 6002;
          jellyfin = 6003;
          radarr = 6005;
          audiobookshelf = 6011;
          komga = 6013;
        };
  };
}
