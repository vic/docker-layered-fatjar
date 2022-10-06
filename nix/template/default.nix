{ pkgs ? import <nixpkgs> {}, ... }:
let
  stream = pkgs.callPackage ./streamImage.nix {};

  dockerLoad = with pkgs; writeShellScript "load-locally" ''
  ${stream} | ${docker-client}/bin/docker load "$@"
  '';

  registryPush = with pkgs; writeShellScript "push-to-registry" ''
  if test -z "''${1:-}"; then
  cat <<-EOF
      USAGE: $0 <docker-url> [skopeo-copy-options]

      Example: $0 docker://some_docker_registry/myimage:tag

      See: https://github.com/containers/skopeo/blob/main/docs/skopeo-copy.1.md
  EOF
    exit 1
  fi
  echo skopeo copy docker-archive:/dev/stdin "$@"
  ${stream} | ${gzip}/bin/gzip --fast | ${skopeo}/bin/skopeo copy docker-archive:/dev/stdin "$@"
  '';

in pkgs.stdenvNoCC.mkDerivation {
  name = "fatjar";
  version = 0;
  phases = [ "install" ];
  install = ''
  mkdir -p $out/bin
  ln -s ${dockerLoad} $out/bin/stream-docker-image
  ln -s ${dockerLoad} $out/bin/load-to-local-docker
  ln -s ${registryPush} $out/bin/copy-to-docker-registry
  '';
}
