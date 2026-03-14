# Part 1: Build-to-Install Path Mapping

The objective of this experiment is to inspect the DWARF debug metadata embedded in a compiled library produced by Spack, using `fmt` as a case study.

---

## Setup

First, we clone Spack and initialize the environment. My user-dedicated `scratch` space on the University of Utah HPC cluster (`/scratch/general/vast/u6059911`) is used as the base directory:

```bash
(base) [u6059911@notchpeak2:u6059911]$ git clone https://github.com/spack/spack.git
(base) [u6059911@notchpeak2:u6059911]$ cd spack
(base) [u6059911@notchpeak2:spack]$ source share/spack/setup-env.sh
```

Then, make the environment persistent across sessions

```bash
(base) [u6059911@notchpeak2:spack]$ echo 'source /scratch/general/vast/u6059911/spack/share/spack/setup-env.sh' >> ~/.bashrc
(base) [u6059911@notchpeak2:spack]$ source ~/.bashrc
```

Next, configure the build stage to use a `scratch` directory:

```bash
(base) [u6059911@notchpeak2:spack]$ mkdir -p ~/.spack
(base) [u6059911@notchpeak2:spack]$ echo -e "config:\n  build_stage:\n    - /scratch/general/vast/u6059911/spack-stage" > ~/.spack/config.yaml
(base) [u6059911@notchpeak2:spack]$ cat ~/.spack/config.yaml
config:
  build_stage:
    - /scratch/general/vast/u6059911/spack-stage
```

Finally, `install` fmt with debug symbols and keep the build stage:

```bash
(base) [u6059911@notchpeak2:u6059911]$ nohup spack install fmt build_type=Debug > spack_fmt_build.log 2>&1 &
```
---

## Method

The following script inspects the DWARF debug metadata present in the installed library files. It uses `readelf` to extract the following attributes:

* `DW_AT_name`: the source file path recorded during compilation
* `DW_AT_comp_dir`: the compilation directory

Both attributes reveal where the compiler believes the source files were located when the binaries were built. 

```bash
(base) [u6059911@notchpeak2:spack_gsoc]$ cat binary_inspection.sh
#!/bin/bash

set -e

PKG=fmt
PREFIX=$(spack location -i $PKG)

echo "Inspecting DWARF build paths for package: $PKG"
echo "Installation prefix: $PREFIX"

LIBS=$(find "$PREFIX" -type f \( -name "*.a" -o -name "*.so" -o -name "*.so.*" \))

echo "Libraries found in the installation prefix: $LIBS"

COMP_DIRS=""

for lib in $LIBS
do
    echo 
    echo "Inspecting DWARF metadata in: $lib"
    OUT=$(readelf --debug-dump=info "$lib" 2>/dev/null | grep DW_AT_comp_dir | grep -o '/.*' || true)
    readelf --debug-dump=info "$lib" 2>/dev/null | grep -E 'DW_AT_(comp_dir|name)' | grep '/' || echo "No DWARF source paths found"
    COMP_DIRS="$COMP_DIRS$OUT"
    echo  
done

echo
echo "Installation prefix:"
echo "$PREFIX"
echo
echo "Compilation directories found in DWARF:"
echo "$COMP_DIRS" | sort -u
```

---

## Results

Running the script produced the following output:

```
(base) [u6059911@notchpeak2:spack_gsoc]$ bash binary_inspection.sh
Inspecting DWARF build paths for package: fmt
Installation prefix: /scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f
Libraries found in the installation prefix: /scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/lib64/libfmtd.a

Inspecting DWARF metadata in: /scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/lib64/libfmtd.a
    <12>   DW_AT_name        : (indirect string, offset: 0x46e2): /scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src/format.cc
    <16>   DW_AT_comp_dir    : (indirect string, offset: 0x91a2): /scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-build-ds5k4qo
    <12>   DW_AT_name        : (indirect string, offset: 0xafbe): /scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src/os.cc
    <16>   DW_AT_comp_dir    : (indirect string, offset: 0x73a8): /scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-build-ds5k4qo


Installation prefix:
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f

Compilation directories found in DWARF:
/scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-build-ds5k4qo
```

Relevant paths extracted from the DWARF metadata:

```bash
DW_AT_name     : /scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src/format.cc
DW_AT_comp_dir : /scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-build-ds5k4qo
```

Recorded compilation directory (`DW_AT_comp_dir`):

```bash
/scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-build-ds5k4qo
```

Installation prefix:

```bash
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f
```


Notably, the recorded compilation directory corresponds to the Spack build stage rather than the installation prefix.

---

## Key Observation

We can see the DWARF debug metadata does not reference the installation prefix. Instead, it contains paths pointing to the Spack build stage directory. To validate the recorded debug paths, we create a minimal test program that links against `fmt` installed with Spack:

```bash
(base) [u6059911@notchpeak2:spack_gsoc]$ cat test_fmt.cpp
#include <fmt/core.h>

int main() {
    fmt::print("Hello {}\n", "Spack");
    return 0;
}
```

Compiling the program:

```bash
(base) [u6059911@notchpeak2:spack_gsoc]$ PREFIX=$(spack location -i fmt)
(base) [u6059911@notchpeak2:spack_gsoc]$ g++ test_fmt.cpp -I$PREFIX/include -L$PREFIX/lib64 -lfmtd -o test_fmt
```

Inspecting the resulting binary with GNU Debugger:

```bash
gdb ./test_fmt
(gdb) info sources
(gdb) info sources
Source files for which symbols have been read in:
Source files for which symbols will be read in on demand:
/usr/include/c++/8/bits/stl_iterator.h, /usr/include/c++/8/bits/alloc_traits.h, /usr/include/c++/8/bits/locale_facets.h, /usr/include/c++/8/bits/locale_classes.tcc, 
/usr/include/c++/8/bits/move.h, /usr/include/c++/8/bits/basic_string.h, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/include/fmt/format-inl.h, 
/usr/include/c++/8/x86_64-redhat-linux/bits/ctype_inline.h, /usr/include/c++/8/bits/locale_classes.h, /usr/include/c++/8/type_traits, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/include/fmt/format.h, /usr/include/c++/8/system_error, 
/usr/include/c++/8/bits/char_traits.h, /scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/include/fmt/base.h, 
/usr/include/c++/8/cmath, /usr/include/c++/8/limits, /usr/include/c++/8/new, /usr/include/c++/8/bits/exception.h, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src/format.cc
```

It reveals source paths pointing to the original Spack build stage, for example `/scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src/format.cc`. And attempting to add the recorded source directory in the debugger:

```bash
(gdb) directory /scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src/
Warning: /scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src: No such file or directory.
Source directories searched: /scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src:$cdir:$cwd
```

This confirms that the DWARF debug metadata embedded in the compiled library records the original compilation directory (`DW_AT_comp_dir`) and source file paths (`DW_AT_name`) from the build stage rather than the final installation prefix. Since the Spack build stage is removed after installation, the debugger cannot automatically locate the referenced source files without additional source path mappings. So this is the final scheme:

![Spack debug path workflow](https://gist.githubusercontent.com/SebastianPaucar/fc147e781e714ba7337fac546ffb162d/raw/spack_debug_workflow.png)

## The Problem Statement

> Write a short technical explanation (200 words) of why simply moving the source code into the installation prefix after the build is finished isn't enough for a debugger to "just work" without extra configuration.


When Spack builds a package like `fmt` with `build_type=Debug`, it compiles the source files in a temporary build stage and generates debug symbols (DWARF) inside the resulting libraries or executables. These debug symbols store absolute paths and metadata to the original source files in the build stage.

For example, in the built `libfmtd.a`, DW_AT_comp_dir pointed to `/scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-build-ds5k4qo` and DW_AT_name pointed to `/scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src/format.cc`

After installation, Spack moves only the compiled binaries and libraries into the installation prefix (`/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f`) and, by default, deletes the build stage. However, the debug symbols embedded in the binaries are not rewritten during this step, so they still reference the original build-stage paths. As a result, a debugger like GNU Debugger cannot locate the source files if they are not present at those exact paths.

Simply moving or copying the source code into the installation prefix does not fix the issue, because the debugger follows the paths stored in the debug symbols. To resolve this mismatch, additional configuration (such as source path remapping) is required so that the debugger can locate the correct source files.