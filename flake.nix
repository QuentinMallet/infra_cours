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
            mdbook
          ];
        };

        packages.doc = pkgs.stdenvNoCC.mkDerivation {
          name = "class-template-doc";
          src = ./docs;
          nativeBuildInputs = [ pkgs.mdbook ];
          buildPhase = "mdbook build";
          installPhase = "cp -r book $out";
        };

        formatter = pkgs.nixfmt-rfc-style or pkgs.nixfmt;
      }
    );
}
