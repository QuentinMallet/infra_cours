{
  description = "Class infrastructure template: Scaleway Kapsule + Argo CD teaching environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            opentofu
            kubectl
            kubernetes-helm
            argocd
            kind
            scaleway-cli
            k9s
            kustomize
            kubeconform
            just
            jq
            yq-go
          ];
        };

        formatter = pkgs.nixfmt-rfc-style or pkgs.nixfmt;
      }
    );
}
