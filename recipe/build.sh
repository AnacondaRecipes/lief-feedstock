#!/bin/bash

set -xeuo pipefail

CMAKE_ARGS="${CMAKE_ARGS} \
  -DBUILD_STATIC_LIBS=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_SKIP_RPATH=ON \
  -DLIEF_EXAMPLES=OFF \
  -DLIEF_OPT_NLOHMANN_JSON_EXTERNAL=ON \
  -DLIEF_OPT_MBEDTLS_EXTERNAL=ON \
  -DLIEF_PYTHON_API=OFF \
"
echo "Python bindings are configured separately in install-py-lief.sh."

# Please keep this comment around. It may help if this problem reoccurs.
# if [[ ${target_platform} =~ linux-* ]]; then
#   # export LDFLAGS="${LDFLAGS} -Wl,--trace -Wl,--cref -Wl,--trace-symbol,_ZTIN4LIEF5MachO16BuildToolVersionE"
#   # export LDFLAGS="${LDFLAGS} -Wl,--trace-symbol,_ZTIN4LIEF5MachO16BuildToolVersionE -Wl,--trace-symbol,_ZTIN4LIEF5MachO12BuildVersionE"
# fi

mkdir -p build

# -L: list cache variables
# -A: list advanced cache variables
# -H: print help string of each cache variable
cmake ${CMAKE_ARGS} -LAH -G "Ninja" -B build \
  -DCMAKE_BUILD_TYPE=Release
