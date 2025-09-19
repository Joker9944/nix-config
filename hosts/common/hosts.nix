_:
let
  nyx = {
    ingress = "192.168.0.128";
  };
in
{
  # redirects for temporary nyx cluster setup
  networking.hosts = {
    ${nyx.ingress} = [
      "idm.vonarx.online"
      "longhorn.vonarx.online"
    ];
  };
}
