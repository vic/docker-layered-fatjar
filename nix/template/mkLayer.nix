{ stdenvNoCC, ... }:
{ contentRoot, n, }: stdenvNoCC.mkDerivation {
  name = "layer-${toString n}";
  version = 0;
  phases = "install";
  src = "${./.}/layer-${toString n}.jar";
  install = ''
  mkdir -p "$out/${contentRoot}"
  cp -r "$src" "$out/${contentRoot}"
  '';
}
