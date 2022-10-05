# docker-layered-fatjar

Use nix to create re-usable Docker layered images from java fat-jar apps.

## Motivation

Deploying fat-jar scala/java applications to kubernetes requires creating a docker
image that normally endups being very big since it has to include at least
a JVM runtime and your fat-jar file. 

However, most of the time, your application code is only a tiny fraction of
what makes up the fat-jar. Most likely all other content just comes from the
libraries and transitive dependencies your project has. Nevertheless, even if
you only make a simple change on your codebase, the whole fat-jar files gets
generated again, which means the docker image also has to be generated again.

Re-creating the image and pushing to a container registry becomes problematic
since each time you are building and sending another >700M image. 
Even if your image includes only a [distroless JVM runtime](https://github.com/GoogleContainerTools/distroless/tree/main/java) 
plus your application fat-jar, you endup re-using almost nothing.

This project is intended to help you split the fat-jar into reusable docker
layers, so that building and pushing to a Container Registry will reuse all
other layers that had not changed.

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
