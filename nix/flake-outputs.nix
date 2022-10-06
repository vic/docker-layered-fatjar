{ nixpkgs, flake-utils, ...}:
let
  global = {};
  per-system = (system:
    let
      pkgs = import nixpkgs { inherit system; };
      main = pkgs.callPackage ./packages/layers-from-fatjar.nix {};
    in
    {
      packages.default = main;
      apps.default = flake-utils.lib.mkApp { drv = main; };
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [ main mill jre_headless docker-client nix-prefetch-docker ];
      };
    });
in global // flake-utils.lib.eachDefaultSystem per-system
