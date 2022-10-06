{ pkgs ? import <nixpkgs> {}, ... }:
let
  cfg = (pkgs.callPackage ./mkConfig.nix {}) {};
in
pkgs.dockerTools.streamLayeredImage cfg
