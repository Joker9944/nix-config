{ lib, vscode-utils, ... }:
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "grafana-alloy";
    publisher = "Grafana";
    version = "0.2.0";
    hash = "sha256-XcoiEDCPp6GzYQDhJArZBEWxSnZrSTHofIyLFegsbh0=";
  };

  meta = {
    description = "Grafana Alloy support";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=Grafana.grafana-alloy";
    homepage = "https://github.com/grafana/vscode-alloy";
    license = lib.licenses.asl20;
  };
}
