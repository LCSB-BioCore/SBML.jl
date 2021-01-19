#!/usr/bin/env julia
using BinaryBuilder, Pkg

julia_version = v"1.5.3"

name = "SBML"
version = v"5.19.0"
sources = [
        ArchiveSource(
          "https://github.com/sbmlteam/libsbml/archive/v5.19.0.tar.gz",
          "127a44cc8352f998943bb0b91aaf4961604662541b701c993e0efd9bece5dfa8"),
        DirectorySource("libsbml-cxxwrapjl", target="wrapper"),
]

script = raw"""

if [[ $target == i686-* ]] || [[ $target == arm-* ]]; then
    export processor=pentium4
else
    export processor=x86-64
fi

# first install SBML to a temp location

cd ${WORKSPACE}/srcdir
SBMLNAME=libsbml-*

cd ${WORKSPACE}/srcdir/${SBMLNAME}
mkdir build
cd build
cmake \
  -DCMAKE_INSTALL_PREFIX=${prefix} \
  -DCMAKE_LIBRARY_PATH=${prefix}/lib \
  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
  -DCMAKE_INCLUDE_PATH="${prefix}/include/libxml2;${prefix}/include" \
  ..
make -j${nproc}
make install

# now the wrapper

cd ${WORKSPACE}/srcdir/wrapper
mkdir build
cd build

SBML_PC_DIR="${prefix}/lib/pkgconfig"

PKG_CONFIG_PATH=$SBML_PC_DIR pkg-config libsbml --cflags --libs

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

LICENSEDIR=${prefix}/share/licenses/SBML
mkdir -p $LICENSEDIR
cp ${WORKSPACE}/srcdir/wrapper/LICENSE $LICENSEDIR/LICENSE-wrapper
cp ${WORKSPACE}/srcdir/${SBMLNAME}/LICENSE.txt $LICENSEDIR/LICENSE-libSBML
cp ${WORKSPACE}/srcdir/${SBMLNAME}/COPYING.txt $LICENSEDIR/COPYING-libSBML
"""

platforms = supported_platforms()
#platforms = [ Linux(:x86_64, libc=:glibc) ]

platforms = expand_cxxstring_abis(platforms)

products = [
    LibraryProduct("libsbml-cxxwrapjl", :libsbml),
]

dependencies = [
    Dependency("libcxxwrap_julia_jll"),
    Dependency("CompilerSupportLibraries_jll"),
    BuildDependency(PackageSpec(name="libjulia_jll", version=julia_version)),
    Dependency("XML2_jll"),
    Dependency("Zlib_jll"),
]

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
    preferred_gcc_version=v"10",
    julia_compat = "$(julia_version.major).$(julia_version.minor)")
