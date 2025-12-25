{ lib, vscode-utils, ... }:
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "quarto";
    publisher = "Quarto";
    version = "1.127.0";
    hash = "sha256-r/eQ+Z3Bq3R1/uKAEvmIqxs1Cwj3dN2ByZ+bz4byudM=";
  };

  meta = {
    description = "Extension for the Quarto scientific and technical publishing system.";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=quarto.quarto";
    homepage = "https://github.com/quarto-dev/quarto/tree/main/apps/vscode";
    license = lib.licenses.agpl3Only;
  };
}
