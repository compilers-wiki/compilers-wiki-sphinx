{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          (python3.withPackages (ps: with ps; [
            sphinx
            pydata-sphinx-theme
            sphinx-intl
          ]))
        ];
      };
    }
    );
}
