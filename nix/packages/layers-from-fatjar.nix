{ lib, pkgs, ... }:
pkgs.stdenvNoCC.mkDerivation {
  name = "layers-from-fatjar";
  version = 0;
  phases = "install";
  buildInputs = [ pkgs.makeWrapper ];
  install = let
    deps = with pkgs; [ bash gawk coreutils
                        docker-client jre_headless
                        nixVersions.stable nix-prefetch-docker
                      ];
  in ''
  mkdir -p $out/bin
  makeWrapper ${./../../bin/layers-from-fatjar} $out/bin/layers-from-fatjar \
    --prefix PATH : ${lib.makeBinPath deps} \
    --set NIX_TEMPLATE "${./../template}"
  '';
}
