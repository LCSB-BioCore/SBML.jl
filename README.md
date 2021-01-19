# SBML.jl

This is a simple wrap of some of the libSBML functionality.

Current status is "under development", something works, more wrapped stuff will
be added by need.

## How to use this

First, build the C++ library and a wrapper and register it in your julia
installation. You need BinaryBuilder for that:

```
Pkg] add BinaryBuilder
```

After the BinaryBuilder is installed, the build script should be able to build
a lot of different versions of the package for possible architectures and
configurations. You usually want to specify a single architecture to build. The
`--deploy` option puts the new package to a place where Julia can find it
later:
```
./build_tarballs.jl x86_64-linux-gnu --deploy=local 
```

After that, you should be able to load the SBML package in Julia:
```
Pkg] dev --local .
julia> using SBML
julia> getLibSBMLDottedVersion()
"5.19.0"
```
