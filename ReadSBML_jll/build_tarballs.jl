#!/usr/bin/env julia
using BinaryBuilder, Pkg

julia_version = v"1.5.3"

name = "ReadSBML"
version = v"0.1.0"
sources = [
        DirectorySource("libreadsbml", target="libreadsbml"),
]

script = raw"""
cd ${WORKSPACE}/srcdir/libreadsbml
mkdir build
cd build

SBML_PC_DIR="${prefix}/lib/pkgconfig"

PKG_CONFIG_PATH=${SBML_PC_DIR} cmake \
  -DCMAKE_INSTALL_PREFIX=${prefix} \
  -DCMAKE_LIBRARY_PATH=${prefix}/lib \
  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
  -DJulia_PREFIX=${prefix} \
  ..
  
make -j${nproc}
make install

# install licenses (note: using `cp` is not fine, but the build env lacks
# `install` version that could do this correctly)

LICENSEDIR=${prefix}/share/licenses/ReadSBML
mkdir -p $LICENSEDIR
cp ${WORKSPACE}/srcdir/libreadsbml/LICENSE $LICENSEDIR/LICENSE
"""

platforms = expand_cxxstring_abis(supported_platforms())

products = [
    LibraryProduct("libreadsbml", :libreadsbml),
]

dependencies = [
    Dependency("libcxxwrap_julia_jll"),
    Dependency("CompilerSupportLibraries_jll"),
    BuildDependency(PackageSpec(name="libjulia_jll", version=julia_version)),
    Dependency("SBML_jll"),
]

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
    preferred_gcc_version=v"10",
    julia_compat = "$(julia_version.major).$(julia_version.minor)")
