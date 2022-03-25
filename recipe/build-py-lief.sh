#!/bin/bash

# Isolate the build.
mkdir -p build_py_${PY_VER}
cd build_py_${PY_VER} || exit 1


# Generate the build files.
echo "Generating the build files."

declare -a CMAKE_EXTRA_ARGS
if [[ ${target_platform} =~ linux-* ]]; then
  echo "Nothing special for linux"
elif [[ ${target_platform} == osx-* ]]; then
  CMAKE_EXTRA_ARGS+=(-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT})
else
  echo "target_platform not known: ${target_platform}"
  exit 1
fi


cmake .. ${CMAKE_ARGS}               \
      -GNinja                        \
      -DCMAKE_PREFIX_PATH=$PREFIX    \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DBUILD_STATIC_LIBS=OFF        \
      -DBUILD_SHARED_LIBS=ON         \
      -DLIEF_PYTHON_API=ON           \
      -DLIEF_EXAMPLES=OFF            \
      -DLIEF_USE_CCACHE=OFF          \
      -DLIEF_INSTALL_PYTHON=ON       \
      \
      -DPYTHON_INCLUDE_DIR:PATH=$(${PYTHON} -c 'from sysconfig import get_paths; print(get_paths()["include"])')  \
      -DPYTHON_LIBRARIES="${PREFIX}"/lib/libpython${PY_VER}.${SHLIB_EXT}  \
      -DPYTHON_LIBRARY="${PREFIX}"/lib/libpython${PY_VER}.${SHLIB_EXT}  \
      -DPYTHON_EXECUTABLE="${PREFIX}"/bin/python  \
      -DPYTHON_VERSION=${PY_VER}     \
      \
      "${CMAKE_EXTRA_ARGS[@]}"       \
      -DCMAKE_BUILD_TYPE=Release

# Build.
echo "Building..."
ninja pyLIEF || exit 1

# Installing
echo "Installing..."
ninja install || exit 1

ext_suffix="$( ${PYTHON} -c 'from sysconfig import get_config_var as get; print(get("EXT_SUFFIX") or get("SO"))' )"
mv api/python/lief${EXT_SUFFIX} ${SP_DIR}/lief${ext_suffix}
if [[ ${target_platform} == osx-* ]]; then
  ${INSTALL_NAME_TOOL:-install_name_tool} -id @rpath/_pylief${ext_suffix} ${SP_DIR}/lief${ext_suffix}
fi

${PYTHON} -c "import lief" || exit 1



# conda run is broken. It does not remove the shell-script-added base-env PATH entries from the
# front of PATH, so when it adds the new env, if there was *another* env activated, then that is
# the one that gets replaced with the PREFIX env PATH entries. Software from the base-env gets
# run instead. This happens on all OSes and this test-code cannot be enabled until conda run is
# free of this problem.
# conda run -p ${PREFIX} --debug-wrapper-scripts which python
# conda run -p ${PREFIX} --debug-wrapper-scripts python -v --version 2>&1 | grep ${PY_VER}
# if [[ ! $? ]]; then
#   echo "conda run runs the wrong python"
#   exit 1
# fi
# conda run -p ${PREFIX} --debug-wrapper-scripts python -v -c "import lief" 2>&1 | grep "The specified module could not be found"
# if [[ ! $? ]]; then
#   echo "conda run ${PREFIX} --debug-wrapper-scripts python \"import lief\" runs the wrong python"
#   exit 1
# fi
