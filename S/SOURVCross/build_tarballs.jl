# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "SOURVCross"
version = v"1.0.0"

# Collection of sources required to complete build
sources = [
    GitSource("https://github.com/KhronosGroup/SPIRV-Cross.git", "6637610b16aacfe43c77ad4060da62008a83cd12")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd SPIRV-Cross/
install_license LICENSE 
CMAKE_FLAGS=()
CMAKE_FLAGS+=(-DCMAKE_BUILD_TYPE=Release)
CMAKE_FLAGS+=(-DCMAKE_INSTALL_PREFIX=${prefix})
CMAKE_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN})
CMAKE_FLAGS+=(-DCMAKE_CROSSCOMPILING:BOOL=ON)
CMAKE_FLAGS+=(-DBUILD_SHARED_LIBS=ON)
CMAKE_FLAGS+=(-DSPIRV_CROSS_SHARED=ON)
mkdir build
cd build 
cmake  ${CMAKE_FLAGS[@]} .. 
sed -i -e 's/soname/install_name/g' CMakeFiles/spirv-cross-c-shared.dir/link.txt
make -j12 VERBOSE=1
make install VERBOSE=1
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    MacOS(:x86_64)
]


# The products that we will ensure are always built
products = [
    LibraryProduct("libspirv-cross-c-shared", :libspirvcross),
    ExecutableProduct("spirv-cross", :spirvcross)
]

# Dependencies that must be installed before this package can be built
dependencies = Dependency[
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; preferred_gcc_version = v"6.1.0")
