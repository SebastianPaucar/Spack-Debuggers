# Spack staging and debugging model (`spack install` vs `spack dev-build`)

Let's start from my `/scratch` directory:

```bash
(base) [u6059911@notchpeak1:~]$ cd /scratch/general/vast/u6059911/gsoc/gsoc_spack
```

Since a custom build stage (/scratch/general/vast/u6059911/spack-stage) was set in `~/.spack/config,yaml`, we remove it and the existing `fmt` installation to restore the default configuration:

```bash
(base) [u6059911@notchpeak2:gsoc_spack]$ rm ~/.spack/config.yaml
(base) [u6059911@notchpeak1:gsoc_spack]$ nohup spack uninstall -afy fmt > spack_uninstall_fmt.log 2>&1 &
(base) [u6059911@notchpeak1:gsoc_spack]$ cat spack_uninstall_fmt.log 
nohup: ignoring input
==> Successfully uninstalled fmt@12.1.0~ipo+pic~shared build_system=cmake build_type=Debug cxxstd=11 generator=make platform=linux os=rocky8 target=skylake_avx512/ds5k4qo
```

Install `fmt` in `Debug` mode (DWARF debug info generated) using Spack's default configuration:

```bash
(base) [u6059911@notchpeak1:gsoc_spack]$ nohup spack install fmt build_type=Debug > spack_install_fmt_Debug_noconfig.log 2>&1 &
```

`spack_install_fmt_Debug_noconfig.log` contains `spack install` pipeline logs (**baseline, normal build**). To compare against the **normal build**, we perform `spack dev-build` using a local clone of the upstream `fmt` repository:

```bash
(base) [u6059911@notchpeak2:gsoc_spack]$ git clone https://github.com/fmtlib/fmt.git
(base) [u6059911@notchpeak2:gsoc_spack]$ git checkout 12.1.0
(base) [u6059911@notchpeak2:gsoc_spack]$ cd fmt
(base) [u6059911@notchpeak2:fmt]$ nohup spack dev-build fmt@12.1.0 build_type=Debug > spack_dev-build_fmt_Debug_noconfig.log 2>&1 &
```

It uses a local working tree instead of Spack's `/spack-src` snapshot and generates debug information (`Debug` build type). Let's list it:

```bash
(base) [u6059911@notchpeak2:fmt]$ spack find -lv fmt
-- linux-rocky8-skylake_avx512 / %c,cxx=gcc@8.5.0 ---------------
dqaxtnh fmt@12.1.0~ipo+pic~shared build_system=cmake build_type=Debug cxxstd=11 dev_path=/scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt generator=make
ds5k4qo fmt@12.1.0~ipo+pic~shared build_system=cmake build_type=Debug cxxstd=11 generator=make
==> 2 installed packages
```

Two installations are present:

* `dqaxtnh`: Dev (`spack dev-build`) build. Built from local repository (`dev_path`) `/scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt`.

* `ds5k4qo`: Normal (`spack install`) build. No `dev_path` field.

> Spack installations are content-addressed by a unique hash (e.g., `ds5k4qo`, `dqaxtnh`). That hash is a **fingerprint** of the full build configuration, including package name, version, compiler, variants, build system, source origin (`spack-src`, `dev_path`), and dependencies. If two users have those same specifications, they get the same hash (same binary layout, each binary is tied to a precise configuration). Two builds does not represent the same installation.

> Even small changes change the hash: adding `-fdebug-prefix-map`, changing compiler flags, editing dependencies. Every experiment produces a new install, not an overwrite. `hash = SHA(full build recipe + dependency graph + source)`. For DWARF study, this allows to compare builds safely (`spack install` vs `spack dev-build` vs modified flags vs ...) in a fully controlled way.

## Normal build installation (`spack install`)

Stage directory of the normal build (hash: `ds5k4qo`):

```bash
(base) [u6059911@notchpeak1:fmt]$ spack location -s /ds5k4qo
/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f
(base) [u6059911@notchpeak2:~]$ ls -d $(spack location -s /ds5k4qo)
ls: cannot access '/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f': No such file or directory
```

The path is recorded by Spack, but it is not on disk anymore. 

> `spack location -s` reports the stage directory used during build. When `spack install` is used, this directory is removed after installation. Spack's model: stage = temporary build workspace. 

From `/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f`, we see Spack sets the **build stage** root `/tmp/$USER/spack-stage/` by default. Note that `/tmp` is on local disk (not NFS) and faster than `$HOME` or shared storage, which makes it important for large packages. Let's see it:

```bash
(base) [u6059911@notchpeak1:fmt]$ ls /tmp/u6059911/spack-stage
spack-src
(base) [u6059911@notchpeak1:fmt]$ ls /tmp/u6059911/spack-stage/spack-src
```

`spack-src` is not a guaranteed active source tree. It is a residual directory in the global stage root. Spack creates `/spack-src` as an extracted source during a normal build and it is scoped inside the stage directory.

> The directory `/tmp/u6059911/spack-stage/spack-src` is part of the **global staging root**, it is an extracted **source tree** (typically from a cached archive or a manual `spack stage`) and corresponds to an **upstream snapshot**, not to a dev repo. It is not tied to a specific build hash. 

When `spack install`, note that a source tree cache is generated in `/var/`:

```bash
(base) [u6059911@notchpeak2:dev-build]$ grep spack_install_fmt_Debug_noconfig.log "cache"
spack_install_fmt_Debug_noconfig.log:==> Using cached archive: /scratch/general/vast/u6059911/spack/var/spack/cache/_source-cache/archive/69/695fd197fa5aff8fc67b5f2bbc110490a875cdf7a41686ac8512fb480fa8ada7.zip
(base) [u6059911@notchpeak2:dev-build]$ unzip -l /scratch/general/vast/u6059911/spack/var/spack/cache/_source-cache/archive/69/695fd197fa5aff8fc67b5f2bbc110490a875cdf7a41686ac8512fb480fa8ada7.zip | head
Archive:  /scratch/general/vast/u6059911/spack/var/spack/cache/_source-cache/archive/69/695fd197fa5aff8fc67b5f2bbc110490a875cdf7a41686ac8512fb480fa8ada7.zip
  Length      Date    Time    Name
---------  ---------- -----   ----
    19680  10-29-2025 08:31   fmt-12.1.0/CMakeLists.txt
     1431  10-29-2025 08:31   fmt-12.1.0/LICENSE
        0  10-29-2025 08:40   fmt-12.1.0/test/
     5502  10-29-2025 08:31   fmt-12.1.0/test/args-test.cc
    17346  10-29-2025 08:31   fmt-12.1.0/test/std-test.cc
        0  10-29-2025 08:40   fmt-12.1.0/test/add-subdirectory-test/
      128  10-29-2025 08:31   fmt-12.1.0/test/add-subdirectory-test/main.cc
```

This `.zip` cached file is used later when `spack stage` to populated `$(spack location -s /ds5k4qo)/spack-src`, but the present of that cached archive does not prevent extraction; it only skips the download step.

> Again, after `spack install`, the stage directory (including `spack-src`) is removed by default as part of Spack's cleanup process.

Let's locate the compiled library artifacts within the Spack installation prefix:

```bash
(base) [u6059911@notchpeak2:fmt]$ find $(spack location -i /ds5k4qo) -name "*.a" -o -name "*.so"
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/lib64/libfmtd.a
```

So a static library `libfmtd.a` (corresponding to a Debug build, since the `d` suffix) was produced. This is the final installed artifact, which means the file is what Spack installs into the prefix, what downstream packages will link against and what contains the DWARF debug info for analyzing.

> While `*.o` files are temporary, not installed intermated build artifacts produced during compilation, `*.a` and `*.so` are installed, reusable final artifacts what the package produces (the primary deliverables of the package). These files are the only surviving containers of build-time information after Spack cleans the stage, and are used by downstream applications during linking and contain embedded DWARF debug metadata.

Let's see what is embedded inside the product:

```bash
(base) [u6059911@notchpeak2:fmt]$ readelf --debug-dump=info $(spack location -i /ds5k4qo)/lib64/libfmtd.a | grep DW_AT_comp_dir
    <16>   DW_AT_comp_dir    : (indirect string, offset: 0x2675e): /tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-build-ds5k4qo
    <16>   DW_AT_comp_dir    : (indirect string, offset: 0xad9e): /tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-build-ds5k4qo
```

`DW_AT_comp_dir` attributes from the DWARF debug information embedded in the installation prefix are extracted. `DW_AT_comp_dir` attribute is part of each DWARF Compilation Unit (CU) and encodes the absolute working directory of the compiler at the time each source file was compiled.

> `/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-build-ds5k4qo` is where CMake configuration is executed, `.o` files are generated, and final `.a` library archives are produced before installation.

Note that the path resides under `/tmp/u6059911/spack-stage/`, which is ephemeral and automatically cleaned by Spack after installation. Despite this, the path is persistently embedded in the installed artifact `libfmtd.a`. Let's verify this:

```bash
(base) [u6059911@notchpeak1:fmt]$ ls /tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-build-ds5k4qo
ls: cannot access '/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-build-ds5k4qo': No such file or directory
```

The stage directory was removed after installation as expected (`spack install`)). The stage directory cleanup does not affect DWARF, the DWARF metadata is generated at compile time and is stored inside object files and preserved during archiving (`.a`), but not post-processed or sanitized by default. Note that `spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-build-ds5k4qo` indicates that the build directory is uniquely tied to the Spack specific hash. Let's verify the original source files referenced in the debug information:

```bash
(base) [u6059911@notchpeak2:~]$  readelf --debug-dump=info $(spack location -i /ds5k4qo)/lib64/libfmtd.a | grep DW_AT_name | grep '/' 
    <12>   DW_AT_name        : (indirect string, offset: 0x2bc8c): /tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src/format.cc
    <12>   DW_AT_name        : (indirect string, offset: 0xebcd): /tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src/os.cc
```

The `DW_AT_name` attribute in DWARF encodes the source file path associated with each Compilation Unit (CU). When combined with `DW_AT_comp_dir`, it provides the full path used by the compiler to locate the source file at build time. `os.cc` and `format.cc` files inside `/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src/` indicate that the compiler operated on source files extracted into the Spack staging directory, originated from `/spack-src/src/` which is the directory where Spack unpacks the upstream source archive (expected from a standard `spack install` workflow). At inspection time:

```bash
(base) [u6059911@notchpeak1:fmt]$ ls  /tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src/
ls: cannot access '/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src/': No such file or directory
```

The referenced paths are stale and DWARF retains references to non-existent filesystem locations.

> Each `.cc` file (e.g., `format.cc`, `os.cc`) produces a separate CU, and each CU records its own DW_AT_name.

> `DW_AT_comp_dir` = build directory. `DW_AT_name` = source file. Absolute paths are embedded in DWARF. These paths include temporary directories (`/tmp`) and hash-dependent stage paths. As a result, binaries differs across builds, debug info is not reproducible and path leakage occurs.

Let's inspect the DWARF line table (`.debug_line`) and source dependencies:

```bash
(base) [u6059911@notchpeak2:~]$ readelf --debug-dump=decodedline $(spack location -i /ds5k4qo)/lib64/libfmtd.a | grep '/' | awk '!seen[$0]++'
File: /scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/lib64/libfmtd.a(format.cc.o)
CU: /usr/include/c++/8/bits/exception.h:
/usr/include/c++/8/new:
/usr/include/c++/8/limits:
/usr/include/c++/8/cmath:
/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/include/fmt/base.h:
/usr/include/c++/8/bits/char_traits.h:
/usr/include/c++/8/system_error:
/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/include/fmt/format.h:
/usr/include/c++/8/type_traits:
/usr/include/c++/8/bits/locale_classes.h:
/usr/include/c++/8/x86_64-redhat-linux/bits/ctype_inline.h:
/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/include/fmt/format-inl.h:
/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src/format.cc:
/usr/include/c++/8/bits/basic_string.h:
/usr/include/c++/8/bits/move.h:
/usr/include/c++/8/bits/locale_classes.tcc:
/usr/include/c++/8/bits/locale_facets.h:
/usr/include/c++/8/bits/alloc_traits.h:
/usr/include/c++/8/bits/stl_iterator.h:
File: /scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/lib64/libfmtd.a(os.cc.o)
/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/include/fmt/os.h:
/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src/os.cc:
```

This is a the complete, de-duplicated list of all source files that contributed to the compiled objects inside `libfmtd.a`. It includes system headers (`/usr/include/c++/*`: C++ dependency, compiler-specific paths,  ABI and tool chain coupling), spack-managed source files (`/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/`: Spack extracted sources such as `include/fmt/base.h`, `include/fmt/format.h`, `include/fmt/os.h`, `src/os.cc` and `src/format.cc`), and object-level granularity (`libfmtd.a(format.cc.o)`: `.a` is an archive of multiple object files where each one has its own line table, and DWARF information is stored per CU). `readelf --debug-dump=decodedline` reconstructs the full transitive source dependency graph used during compilation.

> In a Spack build, this reveals that both project sources (`spack-src/`) and system headers are embedded as absolute paths within DWARF.

## Dev build installation (`spack dev-build`)

Under the `dev-build` installation pipeline, the stage directory is persistent on disk:

```bash
(base) [u6059911@notchpeak1:fmt]$ spack location -s /dqaxtnh
/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc
(base) [u6059911@notchpeak1:fmt]$ ls -d $(spack location -s /dqaxtnh)
/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc
(base) [u6059911@notchpeak1:fmt]$ ls $(spack location -s /dqaxtnh)
spack-build-01-cmake-out.txt    spack-build-03-install-out.txt  spack-build-env-mods.txt        spack-build-out.txt             
spack-build-02-build-out.txt    spack-build-dqaxtnh/            spack-build-env.txt             spack-configure-args.txt        
```

The `spack-stage-fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc` directory was added on `/tmp/u6059911/spack-stage/` when Dev build. Note that the corresponding to `ds5k4qo` is still missing due the cleanup in the normal build installation pipeline:

```bash
(base) [u6059911@notchpeak1:fmt]$ ls /tmp/u6059911/spack-stage/
spack-src  spack-stage-fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc
```

Let's see the final build artifact:

```bash
(base) [u6059911@notchpeak2:fmt]$ find $(spack location -i /dqaxtnh) -name "*.a" -o -name "*.so"
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc/lib64/libfmtd.a
```

The prefix `/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc/` corresponds to the hash `dqaxtnh` as expected. `DW_AT_comp_dir` gives the compilation directory path:

```bash
(base) [u6059911@notchpeak2:fmt]$ readelf --debug-dump=info $(spack location -i /dqaxtnh)/lib64/libfmtd.a | grep DW_AT_comp_dir
    <16>   DW_AT_comp_dir    : (indirect string, offset: 0x2b1b3): /tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc/spack-build-dqaxtnh
    <16>   DW_AT_comp_dir    : (indirect string, offset: 0x3ca1): /tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc/spack-build-dqaxtnh
```

Note that `DW_AT_comp_dir` is still under `/tmp/u6059911/spack-stage/`. 

> `DW_AT_comp_dir` is the compilation directory. It stores the absolute path of the working directory where the compiler was invoked for a given Compilation Unit. This is ephemeral build space, not the install prefix. Remember that `/lib64/libfmtd.a` is the static `.a` library for `fmt` that contains multiple `.o` object files, each with its own DWARF info.

> Note: `readelf --debug-dump=info` dumps the `.debug_info` section. This section contains CUs, Debugging Information Entries (DIEs), and attributes like `DW_AT_name` (source file), `DW_AT_comp_dir` (compile dir), `DW_AT_producer` (compiler), etc.

> Note: Each `<16>` entry shown in the output corresponds to a CU. Each CU has its own `DW_AT_comp_dir`. Each `.o` = one CU, so one `DW_AT_comp_dir`. The `.o` files inside the `.a` are what contain CUs, but they are not the same thing. Each `.o` is produced by one compiler invocation, and it contains machine code (`.txt`), symbols (`.symtab`), and DWARF debug sections (`.debug_info`, `.debug_line`, etc). A CU in DWARF is the debug representation of **one** compilation (typically one source file + its includes after preprocessing). A CU is a top-level DIE inside `.debug_info` with `DW_TAG_compile_unit` as its tag.

> Commonly, 1 `.o` file means 1 CU, so practically `file1.cpp - file1.o - 1 DW_TAG_compile_unit`. Technically, a `.o` can contain multiple CU or event split DWARF references. A `.o` file contains one or more CUs, stored in `.debug_info`.

> When you run `readelf --debug-dump=info libfmtd.a`, `readelf` iterates over each `.o` inside the `.a`. For each `.o`, it reads `.debug_info`. For each CU inside that `.o`, it prints `DW_AT_comp_dir`, `DW_AT_name`, etc.

`DW_AT_comp_dir` responds where each CU (typically corresponding to one source file/object file) was compiled. We can dive into it:

```bash
(base) [u6059911@notchpeak1:fmt]$ ls /tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc/spack-build-dqaxtnh
CMakeCache.txt  cmake_install.cmake    CPackConfig.cmake        fmt-config.cmake          fmt.pc             install_manifest.txt  Makefile
CMakeFiles      compile_commands.json  CPackSourceConfig.cmake  fmt-config-version.cmake  fmt-targets.cmake  libfmtd.a
```

The build directory remains on disk. This is a `dev-build`-native behavior, not the normal Spack installation workflow. `spack dev-build` makes Spack switch to a developer mode, where it intentionally does NOT clean the stage directory and keeps build artifacts and preserves intermediate files. `spack-build-dqaxtnh./` is the actual build directory used by CMake.

> `DW_AT_comp_dir` is literally the CMake build directory where compilation happened. Because the directory still exists, one can now debug with full source mapping: `gdb` can actually work without remapping, since paths are valid.

> DWARF debug info encodes build-time reality, not install-time reality

Let's see a very clean example of how Spack `dev-build` + out-of-source CMake builds + DWARF interact.

> `DW_AT_name` inside a `DW_TAG_compile_unit` is the primary source file of that CU. It represents the file passed to the compiler (e,g. `g++ -c /path/to/src/format.cc`).

```bash
(base) [u6059911@notchpeak2:~]$  readelf --debug-dump=info $(spack location -i /dqaxtnh)/lib64/libfmtd.a | grep DW_AT_name | grep '/' 
    <12>   DW_AT_name        : (indirect string, offset: 0xcf77): /scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt/src/format.cc
    <12>   DW_AT_name        : (indirect string, offset: 0xb63a): /scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt/src/os.cc
(base) [u6059911@notchpeak1:fmt]$ pwd
/scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt
(base) [u6059911@notchpeak1:fmt]$ ls
2                                          ChangeLog.md    CONTRIBUTING.md  include  README.md                               src      test
build-linux-rocky8-skylake_avx512-dqaxtnh  CMakeLists.txt  doc              LICENSE  spack_dev-build_fmt_Debug_noconfig.log  support
(base) [u6059911@notchpeak1:fmt]$ ls /scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt/src/
fmt.cc  format.cc  os.cc
```

Along with the previously `DW_AT_comp_dir` found, we have that each CU encodes `/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc/spack-build-dqaxtnh` as the compilation directory (where compiler ran) and `/scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt/src/*.cc` as the source file (what was compiled).

> Source tree: `/scratch/.../fmt/src/*.cc`. Build tree: `/tmp/.../spack-build-*`. Compiler runs in build tree, but compiles files from source tree.

> CMake uses absolute paths for sources because it avoids ambiguity with include paths and generated files.

> `dev-build` keep the build tree (`/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc/spack-build-dqaxtnh`) and use the working repo already on-disk (`/scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt/src/`). Debuggers like `gdb` can locate sources without any remapping and resolve breakpoints.

> `DW_AT_name` for a `DW_TAG_compile_unit` is derived from the exact path string passed as the input source file to the compiler frontend. If the compiler sees `g++ -c /abs/path/to/src/format.cc`, then DWARF will contain `DW_AT_name = /abs/path/to/src/format.cc`. When `spack dev-build fmt` is ran, Spack uses the existing source tree (the `git` clone) and still performs an out-of-source build, CMake is invoked roughly as `cmake -S /scratch/.../fmt -B /tmp/.../spack-build-<hash>`, where `/scratch/.../fmt` is the source directory and `/tmp/.../spack-build-<hash>` is the build directory. So the workflow is: `dev-build` - source tree is already absolute - CMake propagates absolute paths - compiler sees absolute paths - DWARF stores absolute paths.

> **WITHOUT `dev-build`** (normal `spack install`): both build dir (`spack-build-<hash>`) and source dir (`spack-src`, cloned source) are inside the stage dir. CMake is invoked as `cmake -S /tmp/.../spack-src -B /tmp/.../spack-build-<hash>`, so the compiler sees `g++ -c /tmp/.../spack-src/src/format.cc`, and DWARF would contain `DW_AT_name = /tmp/.../spack-src/src/format.cc`. `dev-build` does not change DWARF semantics,it changes the origin of the source tree.

> **Why DW_AT_comp_dir is still `/tmp`:** The compiler working directory (`cwd`) is `/tmp/.../spack-build-<hash>` that becomes `DW_AT_comp_dir`. So we get a split identity: `DW_AT_name` under `/scratch/` (where the source lives), and `DW_AT_comp_dir` under `/tmp` (where the compilation ran). **Compilation happens in one filesystem context, but consumes sources from another**.

> One can tell Spack to use a specific repo as source tree to run `spack dev-build`. From anywhere, the `fmt` dev-mode installation  can be done by using `spack dev-build fmt@12.1.0 source=/scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt/`. `dev-build` is about binding a package to a source directory. DWARF reflects the path of the source file as seen by the compiler frontend.

Full pipeline:

```bash
git clone fmt → /scratch/.../gsoc_spack/fmt
         ↓
spack dev-build (uses this as source_path)
         ↓
cmake -S /scratch/... -B /tmp/...
         ↓
g++ -c /scratch/.../src/format.cc
         ↓
DW_AT_name = /scratch/.../src/format.cc
DW_AT_comp_dir = /tmp/.../spack-build-*
```

This enables:

* Editing code in-place
* Rebuilding without re-fetching
* Debugging against the working tree
* Iterative development

It is essentially **Spack as a build orchestrator for the repo**, where `dev-build` binds a Spack package to a specific source tree. Let's inspect the DWARF line tables embedded in the static `libfmtd.a` library under the `dev-build` mode:

```bash
(base) [u6059911@notchpeak2:~]$ readelf --debug-dump=decodedline $(spack location -i /dqaxtnh)/lib64/libfmtd.a | grep '/' | awk '!seen[$0]++'
File: /scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc/lib64/libfmtd.a(format.cc.o)
CU: /usr/include/c++/8/bits/exception.h:
/usr/include/c++/8/new:
/usr/include/c++/8/limits:
/usr/include/c++/8/cmath:
/scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt/include/fmt/base.h:
/usr/include/c++/8/bits/char_traits.h:
/usr/include/c++/8/system_error:
/scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt/include/fmt/format.h:
/usr/include/c++/8/type_traits:
/usr/include/c++/8/bits/locale_classes.h:
/usr/include/c++/8/x86_64-redhat-linux/bits/ctype_inline.h:
/scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt/include/fmt/format-inl.h:
/scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt/src/format.cc:
/usr/include/c++/8/bits/basic_string.h:
/usr/include/c++/8/bits/move.h:
/usr/include/c++/8/bits/locale_classes.tcc:
/usr/include/c++/8/bits/locale_facets.h:
/usr/include/c++/8/bits/alloc_traits.h:
/usr/include/c++/8/bits/stl_iterator.h:
File: /scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc/lib64/libfmtd.a(os.cc.o)
CU: /scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt/include/fmt/base.h:
/scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt/include/fmt/os.h:
/scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt/src/os.cc:
```

Output confirms compilation against:

* `dev-build` source tree `/scratch/general/vast/u6059911/gsoc/gsoc_spack/fmt/, that comes from the local `git` clone, and used as `dev_path` by `spack dev-build`. This matches `DW_AT_name` an confirms compilation against the working tree.
* system headers `/usr/include/c++/8/` originated from the compiler toolchain GCC 8 libstdc++, and captured because DWARF records all header dependencies used during preprocessing.

The installed archive container `/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc/lib64/libfmtd.a(os.cc.o)` reflects the final install prefix (Spack store), and the `.a` archive wrapping the `.o` files. 

> `readelf --debug-dump=decodedline` dumps the `.debug_line` section, which encodes the DWARF line number program for each CU. `.debug_line` contains a file table listing all source and header files referenced during compilation. The full command lists the unique set of files referenced by each CU.

> **Object-level granularity:** Each block `File: /scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc/lib64/libfmtd.a(os.cc.o)` corresponds to one object file (`.o`) inside the archive (`.a`) and one CU in DWARF terms.

> **CU file table:** The files under each `CU:` block corresponds to the DWARF line table file entries, representing all files that contributed to the generated machine code for this CU. This includes the **primary source file (`format.cc`, `os.cc`)** and all transitive included headers (`fmt/*.h` project headers, `/usr/include/c++/...` system headers).

> For each CU, `.debug_info` defines `DW_TAG_compile_unit`, `DW_AT_name` (primary source file), `DW_AT_comp_dir` (compilation directory).

> For each CU, `.debug_line` defines a state machine program (DWARF line program) and a file name table. The DWARF line table encodes the complete compilation dependency closure of each object file, that is `source file + all included headers - preprocessed translation unit - machine code`, and DWARF records every file that contributed to that translation unit. This demonstrates how DWARF captures full include graph and absolute path provenance. DWARF debug information is not limited to symbol-level metadata, it encodes a full, path-resolved view of the translation unit dependency graph as seen by the compiler. The resulting binary contains a composite view of build + source + toolchain environments. 


## `spack stage` post-`spack install`

Materializyng the Spack staging area for `fmt` normal installation:

```bash
(base) [u6059911@notchpeak2:fmt]$ spack stage fmt
==> Using cached archive: /scratch/general/vast/u6059911/spack/var/spack/cache/_source-cache/archive/69/695fd197fa5aff8fc67b5f2bbc110490a875cdf7a41686ac8512fb480fa8ada7.zip
==> Staged fmt in /tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f
```

From the cached archive, the command produces the directory structure:

```bash
(base) [u6059911@notchpeak1:fmt]$  ls  /tmp/u6059911/spack-stage
spack-src  spack-stage-fmt-12.1.0-dqaxtnhxjvbec63xny233wl2a2xgzrkc  spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f
```

The `*-ds5k4qo*` directory is the generated one, the`*-dqaxtnh*` is the `dev-build` installed one (already existing adn persitent in `/tmp/u6059911/spack-stage`). Let's see what is inside `spack-src/`:

```bash
(base) [u6059911@notchpeak2:~]$ ls /tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/
ChangeLog.md  CMakeLists.txt  CONTRIBUTING.md  doc  doc-html  include  LICENSE  README.md  src  support  test
```

We confirm this is the extracted source tree. `spack stage` reuses `/scratch/general/vast/u6059911/spack/var/spack/cache/_source-cache/` cached content to fetch the source archive then unpacks under `/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/`. `spack-src` is the canonical source tree used for building, equivalent to a fresh clone or release tarball. During a normal build (`spack install`), Spack creates:

```bash
/tmp/.../spack-stage-fmt-<hash>/
 ├── spack-src/        ← source directory (CMAKE_SOURCE_DIR)
 └── spack-build-<hash>/ ← build directory (CMAKE_BINARY_DIR)
```

CMake is invoked as `cmake -S spack-src -B spack-build-<hash>`. If the build uses the staged source `/tmp/.../spack-stage-.../spack-src`, the compiler invokation looks like `g++ -c /tmp/.../spack-src/src/format.cc`, so DWARF contains `DW_AT_name = /tmp/.../spack-src/src/format.cc` and `.debug_line` includes `/tmp/.../spack-src/include/fmt/...`, so:

> `spack stage` reveals the exact source tree that would be used in a standard Spack build, and therefore predicts the paths that would be embedded in DWARF debug information. The staging directory is the ground truth for source provenance during compilation, and its filesystem location directly propagates into DWARF debug information unless explicitly sanitized.