{
  lib,
  vscode-utils,
}:
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "code-spell-checker-swiss-german";
    publisher = "streetsidesoftware";
    version = "1.2.3";
    hash = "sha256-CY/2g0ufsxFcEL+hznde/NFzsgb7SdBPFxFlz/vfwPA=";
  };
  meta = {
    changelog = "https://marketplace.visualstudio.com/items/streetsidesoftware.code-spell-checker-swiss-german/changelog";
    description = "Swiss German dictionary extension for VS Code.";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker-swiss-german";
    homepage = "https://github.com/streetsidesoftware/vscode-cspell-dict-extensions#readme";
    license = lib.licenses.gpl3Only;
  };
}
