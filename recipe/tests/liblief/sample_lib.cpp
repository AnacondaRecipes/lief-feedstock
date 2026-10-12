// Tiny shared library that is built by the test and then parsed by LIEF.
#if defined(_WIN32)
#define SAMPLE_API extern "C" __declspec(dllexport)
#else
#define SAMPLE_API extern "C" __attribute__((visibility("default")))
#endif

SAMPLE_API int sample_add(int a, int b) {
  return a + b;
}
