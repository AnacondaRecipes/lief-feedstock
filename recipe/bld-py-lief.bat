:: cmd

:: Determine the name of the interface library.
for /F "tokens=1,2 delims=. " %%a in ("%PY_VER%") do (
   set "PY_MAJOR=%%a"
   set "PY_MINOR=%%b"
)
set PY_LIB=python%PY_MAJOR%%PY_MINOR%.lib


:: Isolate the build.
mkdir build_py
cd build_py
if errorlevel 1 exit /b 1


:: Generate the build files.
echo "Generating the build files."
cmake .. %CMAKE_ARGS%                         ^
      -G"Ninja"                               ^
      -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%    ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DBUILD_STATIC_LIBS=OFF                 ^
      -DBUILD_SHARED_LIBS=ON                  ^
      -DLIEF_PYTHON_API=ON                    ^
      -DLIEF_EXAMPLES=OFF                     ^
      -DLIEF_USE_CCACHE=OFF                   ^
      -DLIEF_INSTALL_PYTHON=ON                ^
      ^
      -DPYTHON_EXECUTABLE=%PREFIX%\python.exe    ^
      -DPYTHON_LIBRARIES=%PREFIX%\libs\%PY_LIB%  ^
      -DPYTHON_LIBRARY=%PREFIX%\libs\%PY_LIB%    ^
      -DPYTHON_INCLUDE_DIR:PATH=%PREFIX%\include ^
      -DPYTHON_VERSION=%PY_VER%                  ^
      ^
      -DCMAKE_BUILD_TYPE=Release

if %errorlevel% neq 0 exit /b 1


:: If we do not create this directory, then a cmake copy command will copy a pyd to a file
:: called lief, instead of putting it in that directory (or so it seems at least).
mkdir api\python\lief


:: when DEBUG_C, the first run will download pybind11 sources which will cause a build failure
:: at best, and a broken .pyd at worst because pybind11 undefines _DEBUG just before including
:: Python.h. We undo that.

:: Build.
echo "Building..."
ninja -v pyLIEF


:: Install.
echo "Installing..."
ninja -v install


:: We end up with an exe called lief which is weird.
cd api\python

:: We may want to have our own dummy setup.py so we get a dist-info folder. It would
:: be nice to use LIEF's setup.py but it places too many constraints on the build.
:: %PYTHON% setup.py install --single-version-externally-managed --record=record.txt
copy lief\lief.pyd %SP_DIR%\lief.pyd


:: Error free exit.
echo "Error free exit!"
exit 0
