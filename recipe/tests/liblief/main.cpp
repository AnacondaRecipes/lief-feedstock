// Minimal cross-platform (Linux / macOS / Windows x64 + ARM64) LIEF app that
// shows where tl::expected leaks into user code.
//
// It uses the format-agnostic API (LIEF::Parser / LIEF::Binary), so the same
// code handles ELF, PE and Mach-O inputs on any host.
//
// Note: there is no explicit #include <tl/expected.hpp> here. It is pulled in by
//   LIEF/LIEF.hpp -> Abstract/Binary.hpp -> LIEF/errors.hpp
//   -> LIEF/third-party/expected.hpp -> <tl/expected.hpp>
#include <cstdint>
#include <iostream>
#include <memory>

#include <LIEF/LIEF.hpp>

// Print the numeric LIEF error code
static uint32_t error_code(lief_errors err) {
  return static_cast<uint32_t>(err);
}

int main(int argc, char** argv) {
  if (argc != 2) {
    std::cerr << "Usage: " << argv[0] << " <elf|pe|macho>\n";
    return 1;
  }

  // Parser::parse returns unique_ptr: no expected involved in the call itself.
  std::unique_ptr<LIEF::Binary> bin = LIEF::Parser::parse(argv[1]);
  if (!bin) {
    std::cerr << "Can't parse " << argv[1] << "\n";
    return 1;
  }

  std::cout << "format:      " << LIEF::to_string(bin->format()) << "\n";
  std::cout << "entrypoint:  0x" << std::hex << bin->entrypoint() << std::dec << "\n";

  // LIEF::result<T> == tl::expected<T, lief_errors>
  // Offset 0 is valid in every format, so this should succeed.
  LIEF::result<uint64_t> va = bin->offset_to_virtual_address(0);
  if (va) {  // tl::expected::operator bool
    std::cout << "VA of offset 0: 0x" << std::hex << *va << std::dec << "\n";
  } else {
    // tl::expected::error() returns lief_errors
    std::cout << "offset_to_virtual_address failed: error " << error_code(va.error()) << "\n";
  }

  // value_or() is a tl::expected member. A missing symbol yields the fallback.
  uint64_t addr = bin->get_function_address("main").value_or(0);
  std::cout << "main:        0x" << std::hex << addr << std::dec << "\n";

  // ok_error_t == result<ok_t>
  LIEF::ok_error_t status = LIEF::ok();
  if (LIEF::is_err(status)) {
    std::cerr << "error " << error_code(status.error()) << "\n";
    return 1;
  }

  // Creating an error yourself returns tl::unexpected<lief_errors>
  LIEF::result<uint64_t> failed = make_error_code(lief_errors::not_found);
  std::cout << "forced err:  " << error_code(failed.error()) << "\n";

  return 0;
}
