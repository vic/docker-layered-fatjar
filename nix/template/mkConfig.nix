# see: https://nixos.org/manual/nixpkgs/stable/#ssec-pkgs-dockerTools-buildLayeredImage
{ pkgs, ... }:
cfg:
let
  args = pkgs.callPackage ./args.nix {};
  inherit (args) nLayers main contentRoot;
  mkLayer = pkgs.callPackage ./mkLayer.nix {};
  layers = builtins.genList (n: mkLayer { inherit n contentRoot; }) nLayers;
  jars = builtins.genList(n: "${contentRoot}/layer-${toString n}.jar") nLayers;
  classpath = pkgs.lib.concatStringsSep ":" jars;
  baseImage = pkgs.dockerTools.pullImage (import ./baseImage.nix);
in
{
  fromImage = baseImage;

  name = cfg.name or "fatjar";

  contents = layers;

  enableFakechroot = false;

  # Run-time configuration of the container. A full list of the options are available at in the Docker Image Specification v1.2.0.
  # https://github.com/moby/moby/blob/master/image/spec/v1.2.md#image-json-field-descriptions
  config = let
    env =  {
      Env = [ ''CLASSPATH="${classpath}"'' ];
      Cmd = [];
    };
    entry = if main == "" then {} else { Entrypoint = [ "java" "-cp" classpath main ]; };
  in env // entry;
}
