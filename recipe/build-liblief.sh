#!/bin/bash


# Isolate the build.
mkdir -p build_c
cd build_c || exit 1


# Generate the build files.
echo "Generating the build files."

declare -a CMAKE_EXTRA_ARGS
if [[ ${target_platform} == osx-* ]]; then
    CMAKE_EXTRA_ARGS+=(-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT})
    CMAKE_EXTRA_ARGS+=(-DCMAKE_SKIP_RPATH=ON)
elif [[ ${target_platform} == linux-ppc64le ]]; then
    CMAKE_EXTRA_ARGS+=(-DLIEF_LOGGING=OFF)
fi

cmake .. ${CMAKE_ARGS}               \
      -GNinja                        \
      -DCMAKE_PREFIX_PATH=$PREFIX    \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DBUILD_STATIC_LIBS=OFF        \
      -DBUILD_SHARED_LIBS=ON         \
      -DLIEF_PYTHON_API=OFF          \
      -DLIEF_TESTS=OFF               \
      -DLIEF_EXAMPLES=OFF            \
      -DLIEF_USE_CCACHE=OFF          \
      "${CMAKE_EXTRA_ARGS[@]}"       \
      -DCMAKE_BUILD_TYPE=Release


# Build.
echo "Building..."
ninja || exit 1


# Perform tests.
echo "Testing..."
echo "   ...currently disabled."
#  ninja test || exit 1
#  path_to/test || exit 1
#  ctest -VV --output-on-failure || exit 1


# Installing
echo "Installing..."
ninja install || exit 1


# Error free exit!
echo "Error free exit!"
exit 0
