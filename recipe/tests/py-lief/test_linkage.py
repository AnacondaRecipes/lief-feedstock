"""Check that the py-lief extension module is dynamically linked against libLIEF.

Select the extension module's imports that are provided by libLIEF, assert
that this selection is non-empty (so the check cannot pass vacuously), and
then assert that every selected import is actually exported by libLIEF.
"""

import ctypes.util
import sys

import lief

ext_path = lief._lief.__file__
lib_path = ctypes.util.find_library("LIEF")
assert lib_path, "could not locate the LIEF shared library"

ext = lief.parse(ext_path)
lib = lief.parse(lib_path)
assert ext is not None, f"could not parse {ext_path}"
assert lib is not None, f"could not parse {lib_path}"

if sys.platform == "win32":
    # PE: imports are grouped by providing DLL; the C++ mangling of MSVC does not
    # contain "4LIEF", so select by DLL name instead.
    # DLL names are case-insensitive on Windows.
    imported = {
        entry.name
        for imp in ext.imports
        if imp.name.lower() == "lief.dll"
        for entry in imp.entries
        if not entry.is_ordinal and entry.name
    }
else:
    # ELF/Mach-O: imports do not record their provider (flat/two-level namespace
    # aside), so select the C++ symbols living in the LIEF namespace.
    imported = {s.name for s in ext.imported_functions if "4LIEF" in s.name}

assert imported, f"no imports from LIEF found in {ext_path}; linkage not verified"
print(f"{len(imported)} symbols imported from LIEF by {ext_path}")

exported = {s.name for s in lib.exported_functions}
missing = imported - exported
assert not missing, f"{len(missing)} imported symbols not exported by {lib_path}: {sorted(missing)[:20]}"
