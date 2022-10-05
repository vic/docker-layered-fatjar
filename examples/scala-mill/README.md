

``` sh
# Check hello works locally.
mill hello

# Manually split layers.
mill show hello.assembly 
layers-from-fatjar --jars out/hello/assembly.dest/out.jar
```
