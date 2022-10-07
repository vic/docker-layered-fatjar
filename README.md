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

This program will expand a fatjar and use the du utility to find directories
that are over a size threshold (default 2M) and create a separate jar for 
each of those directories. 

It can also be given a list of explicit directories to separate into a layer
using the --add-layer option. See --help.

It's also possible to create a layer containing only the fatjar toplevel files
which will change only if you edit /application.conf for example.

### Installation


* If you already have Nix installed, you can run it directly using:

```
# Run directly using this project flake.
nix run github:vic/docker-layered-fatjar -- --help

# Or install it locally if you prefer. Installed binary is named: layers-from-fatjar
nix profile install github:vic/docker-layered-fatjar
layers-from-fatjar --help
```

* If you dont have Nix, you can still download the `bin/layers-from-fatjar` script and
make sure your system has [this dependencies installed](https://github.com/vic/docker-layered-fatjar/blob/main/nix/packages/layers-from-fatjar.nix#L8)



### Usage

The following will split `fatjar.jar` file and build a docker image named `myapp:layered`

```
nix run github:vic/docker-layered-fatjar -- --docker-build fatjar.jar -- --tag myapp:layered
```

