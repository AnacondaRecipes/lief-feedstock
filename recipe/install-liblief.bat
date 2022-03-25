:: cmd


:: Isolate the build.
mkdir build_c
cd build_c
if errorlevel 1 exit /b 1


:: Generate the build files.
echo "Generating the build files."
cmake .. %CMAKE_ARGS%                         ^
      -G"Ninja"                               ^
      -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%    ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_SKIP_RPATH=ON                   ^
      -DLIEF_PYTHON_API=OFF                   ^
      -DLIEF_TESTS=ON                         ^
      -DLIEF_EXAMPLES=OFF                     ^
      -DLIEF_USE_CCACHE=OFF                   ^
      -DCMAKE_BUILD_TYPE=Release

:: Build.
echo "Building..."
ninja
if errorlevel 1 exit /b 1


:: Perforem tests.
::  echo "Testing..."
::  ninja test
::  path_to\test
::  ctest -VV --output-on-failure
::  if errorlevel 1 exit /b 1


:: Install.
echo "Installing..."
ninja install
if errorlevel 1 exit /b 1


:: Error free exit.
echo "Error free exit!"
exit 0
