{ lib, vscode-utils, ... }:
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "vscode-gitops-tools";
    publisher = "Weaveworks";
    version = "0.27.0";
    hash = "sha256-7MCKDnHCot/CL/SqZ2WuTxbqFdF75EC5WC+OxW0dcaE=";
  };

  meta = {
    changelog = "https://marketplace.visualstudio.com/items/Weaveworks.vscode-gitops-tools/changelog";
    description = "GitOps automation tools for continuous delivery of Kubernetes and Cloud Native applications";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=Weaveworks.vscode-gitops-tools";
    homepage = "https://github.com/weaveworks/vscode-gitops-tools";
    license = lib.licenses.mpl20;
  };
}
