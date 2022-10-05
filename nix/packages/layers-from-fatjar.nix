{ lib, makeWrapper, coreutils, docker-client, jre_headless, stdenvNoCC, ... }:
stdenvNoCC.mkDerivation {
  name = "layers-from-fatjar";
  version = 0;
  phases = "install";
  buildInputs = [ makeWrapper ];
  install = ''
  mkdir -p $out/bin
  makeWrapper ${./../../bin/layers-from-fatjar} $out/bin/layers-from-fatjar \
    --prefix PATH : ${lib.makeBinPath [ coreutils docker-client jre_headless ]}
  '';
}
