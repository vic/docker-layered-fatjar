# docker-layered-fatjar

Use nix to create re-usable Docker layered images from java fat-jar apps.

## Motivation

Deploying fat-jar applications to kubernetes can become 

 When creating docker images it's much better to re-use previous layers
 that have not changed. This utility allows us to re-use most of the
 content from a fat jar.

### How

 Splits an assembly-jar (FAT.jar) into many layers intended for building
 a layered Docker image.

 It will create a layers.nix file containing derivations for each directory.
 This layers.nix can be used as contents for pkgs.dockerTools.streamLayeredImage.
 See: terraform/nix/terrniax/lib/layered-image.nix

 The strategy for separating layers is using the following command to determine
 which directories inside the jar are greater than 2M:

 (mkdir exapanded; cd expanded; jar -xvf assembly.jar) && \
 (du -h expanded/ -t 2M -S | sort -hr)

 All top level files (application.conf, jquery.js, etc) in a single layer.

###
 Usage: bin/split-assembly-jar [assembly.jar] [target-directory]

 Each resulting subdirectory of [target-directory] can be considered a layer.
