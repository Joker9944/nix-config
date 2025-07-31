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
    description = "Syntax highlighting, validation, formatting, and JSON schema based intellisense / completion for JSON5 files in Visual Studio Code.";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=BlueGlassBlock.better-json5";
    homepage = "https://github.com/BlueGlassBlock/better-json5";
    license = lib.licenses.mit;
  };
}
