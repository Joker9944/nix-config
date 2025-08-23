{
  lib,
  vscode-utils,
}:
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "better-json5";
    publisher = "BlueGlassBlock";
    version = "1.6.0";
    hash = "sha256-ySGU7LZqymZBfsKaVwKrqrIMGEItBMea5LM+/DHABFM=";
  };
  meta = {
    changelog = "https://marketplace.visualstudio.com/items/blueglassblock.better-json5/changelog";
    description = "JSON5 highlighter + intellisense + formatter + validator for VS Code";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=BlueGlassBlock.better-json5";
    homepage = "https://github.com/BlueGlassBlock/better-json5#readme";
    license = lib.licenses.mit;
  };
}
