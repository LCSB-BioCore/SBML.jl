
# libSBML CxxWrap julia integration

Dependencies:
- libSBML installed in `SBMLPREFIX` (replace below)
- `CxxWrap` package installed in Julia

Compilation:
```sh
mkdir build; cd build

PKG_CONFIG_PATH=$SBMLPREFIX/lib/pkgconfig cmake \
  -DCMAKE_INSTALL_PREFIX=$SBMLPREFIX \
  -DCMAKE_PREFIX_PATH=`julia -e 'using CxxWrap; println(CxxWrap.prefix_path());'` \
  ..

make
```

You can use `make install` to actually install it to the SBML prefix location,
but the library can also be loaded right from the build directory.

Loading from Julia:
```julia
module SBML
  using CxxWrap
  @wrapmodule("path-to-build/libsbml-cxxwrapjl.so")
  function __init__()
    @initcxx
  end
end
```

Usage from Julia:
```julia
julia> SBML.getLibSBMLDottedVersion()
"5.19.0"
```
