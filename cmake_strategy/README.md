# Part 3: CMake Configuration Analysis

Many Spack packages use CMake with out-of-source builds. Here, we analyze ROOT as an example and propose a strategy to preserve its source files during the build.

## Analyze a `package.py` file

From the ROOT `package.py` file, we can find the CMake entries and variables via `grep`:

```bash
(base) [u6059911@notchpeak2:u6059911]$ grep -i cmake  $(spack location -p root)/package.py
from spack_repo.builtin.build_systems.cmake import CMakePackage
class Root(CMakePackage):
    # Support recent versions of protobuf with their own CMake config
    # (provided the CMake being used supports targets), _cf_
    patch("protobuf-config.patch", level=0, when="@:6.30.02 ^protobuf ^cmake@3.9:")
    depends_on("cmake@3.9:", type="build", when="@6.18.00:")
    depends_on("cmake@3.16:", type="build", when="@6.26.00:")
    depends_on("cmake@3.19:", type="build", when="@6.28.00: platform=darwin")
    depends_on("cmake@3.20:", type="build", when="@6.34.00:")
    depends_on("lz4", when="@6.13.02:")  # See cmake_args, below.
    depends_on("xxhash", when="@6.13.02:")  # See cmake_args, below.
    def cmake_args(self):
            options.extend([define("CMAKE_C_FLAGS", cflags), define("CMAKE_CXX_FLAGS", cflags)])
            options.append(define_from_variant("CMAKE_CXX_STANDARD", "cxxstd"))
            options.append(define("CMAKE_INSTALL_RPATH", self.prefix.lib.root))
            env.append_path("CMAKE_PREFIX_PATH", spec["lz4"].prefix)
        # use CMake. To resolve this, we must bring back those dependencies's
        env.append_path("CMAKE_MODULE_PATH", self.prefix.cmake)
```

This reveals:

* `class Root(CMakePackage)` confirms ROOT is CMake-based and uses out-of-source builds.
* The `depends_on("cmake@...")` lines indicate the minimum required versions of CMake for different ROOT releases. This ensures that the correct CMake features are available during the build.
* `def cmake_args(self):` defines variables passed to CMake, such as `CMAKE_C_FLAGS`, `CMAKE_CXX_FLAGS`, `CMAKE_CXX_STANDARD`, `CMAKE_INSTALL_RPATH`, `CMAKE_PREFIX_PATH` and `CMAKE_MODULE_PATH`. In the context of source preservation, this function shows where Spack interacts with CMake and where we could capture variables pointing to the source directories.

## The Question

> If we wanted to automate the installation of source files, which CMake variables (e.g., CMAKE_SOURCE_DIR, PROJECT_SOURCE_DIR) would Spack need to capture during the build phase to know exactly what to copy? List at least three relevant variables and explain their role in this context.


To automate the installation of source files in a CMake-based package like ROOT, Spack should capture `CMAKE_SOURCE_DIR`, `PROJECT_SOURCE_DIR`, and `CMAKE_CURRENT_SOURCE_DIR`. These variables indicate the top-level source tree, the current project’s source directory, and the specific directory being processed by CMake, respectively. By capturing them during the build phase, Spack can locate all relevant source files, including those in nested subdirectories, and copy them to the installation prefix while avoiding build artifacts. An approach inspired by the “Keep-Source” Hook” prototype developed before is useful:

* During the configuration phase, record `CMAKE_SOURCE_DIR`, `PROJECT_SOURCE_DIR`, and `CMAKE_CURRENT_SOURCE_DIR` by inspecting `CMakeCache.txt` or via `cmake_args()` in `package.py`.
* Before the stage is cleaned, copy all relevant source files (*.h, *.hpp, *.c, *.cc, *.cpp) from `spack-src` and place the sources in a dedicated directory.
* Maintain the original subdirectory hierarchy so that debuggers and development tools can locate the sources easily.

> How would you handle a package that generates source code during the build (like Lex/Yacc or Protobuf)? Should that generated code be installed in the prefix too?

For packages that generate source code during the build, a build-to-install path mapping approach as done before can be applied: Spack can capture the directories where generated sources are produced, using CMake variables such as `CMAKE_CURRENT_SOURCE_DIR` and `PROJECT_SOURCE_DIR` to locate them, perform binary inspection to determine which generated files are actually referenced by the compiled artifacts, and conduct a metadata hunt to capture relevant build paths. Generated sources that are required for debugging or downstream development should be installed into a dedicated directory under the installation prefix (e.g., `prefix/share/<package>/src`), ensuring consistency between build-time paths and installed files while intermediate generated files that are not needed can be safely omitted to avoid clutter.