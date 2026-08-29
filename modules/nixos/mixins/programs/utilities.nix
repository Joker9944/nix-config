{ mkMixinModule, ... }:
{ pkgs, ... }:
mkMixinModule "utilities" {
  environment.systemPackages = with pkgs; [
    # commands
    curl
    wget
    dig
    jq
    yq
    openssl
    pciutils
    file

    # languages
    python3
  ];
}
