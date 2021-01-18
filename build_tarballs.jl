#!/usr/bin/env julia
using BinaryBuilder, Pkg

# This needs unprivileged containers:
# sysctl kernel.unprivileged_userns_clone=1

name = "SBML"
version = v"5.19.0"
sources = [
        ArchiveSource(
          "https://github.com/sbmlteam/libsbml/archive/v5.19.0.tar.gz",
          "127a44cc8352f998943bb0b91aaf4961604662541b701c993e0efd9bece5dfa8"),
        DirectorySource("libsbml-cxxwrapjl", target="wrapper"),
]

script = raw"""
find ${prefix}
cd ${WORKSPACE}/srcdir/libsbml-5.19.0
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${WORKSPACE}/srcdir/libsbml-install -DCMAKE_INCLUDE_PATH="${prefix}/include/libxml2;${prefix}/include" -DCMAKE_LIBRARY_PATH=${prefix}/lib ..
make -j${nproc}
make install
cd ${WORKSPACE}/srcdir/wrapper
mkdir build
cd build
PKG_CONFIG_PATH=${WORKSPACE}/srcdir/libsbml-install/lib/pkgconfig cmake -DCMAKE_INSTALL_PREFIX=${prefix} ..
make -j${nproc}
make install
"""

#platforms = supported_platforms()
platforms=[
    Linux(:x86_64, libc=:glibc),
]

products = [
    LibraryProduct("libsbml-cxxwrapjl", :libsbml),
]

dependencies = [
    Dependency("libcxxwrap_julia_jll"),
    BuildDependency(PackageSpec(name="Julia_jll")), #see ygdrassil/SDPA
    Dependency("XML2_jll"),
    Dependency("Zlib_jll"),
]

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
