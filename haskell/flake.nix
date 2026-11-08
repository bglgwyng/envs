# ~/envs/haskell/flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        hp = pkgs.haskellPackages;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            hp.ghc
            hp.haskell-language-server
            pkgs.cabal-install
          ];
        };
      }
    );
}
