```bash
(base) [u6059911@notchpeak2:cuda_test]$ spack -ddd fetch cuda@12.9.1 > spack-fetch_cuda.log 2>&1 &
```

```bash
(base) [u6059911@notchpeak2:cuda_test]$ find /scratch/general/vast/u6059911/spack-stage -name "cuda*.run"
/scratch/general/vast/u6059911/spack-stage/spack-stage-cuda-12.9.1-obbkqgpuhmf2zqxzigd5hxjie5up7qhn/cuda_12.9.1_575.57.08_linux.run
(base) [u6059911@notchpeak2:cuda_test]$ ls -lh /scratch/general/vast/u6059911/spack-stage/spack-stage-cuda-12.9.1-obbkqgpuhmf2zqxzigd5hxjie5up7qhn/cuda_12.9.1_575.57.08_linux.run
-rw-r--r-- 1 u6059911 nineil 5.5G May  9 18:29 /scratch/general/vast/u6059911/spack-stage/spack-stage-cuda-12.9.1-obbkqgpuhmf2zqxzigd5hxjie5up7qhn/cuda_12.9.1_575.57.08_linux.run
(base) [u6059911@notchpeak2:cuda_test]$ sha256sum  /scratch/general/vast/u6059911/spack-stage/spack-stage-cuda-12.9.1-obbkqgpuhmf2zqxzigd5hxjie5up7qhn/cuda_12.9.1_575.57.08_linux.run
0f6d806ddd87230d2adbe8a6006a9d20144fdbda9de2d6acc677daa5d036417a  /scratch/general/vast/u6059911/spack-stage/spack-stage-cuda-12.9.1-obbkqgpuhmf2zqxzigd5hxjie5up7qhn/cuda_12.9.1_575.57.08_linux.run
```

```bash
(base) [u6059911@notchpeak2:cuda_test]$ time spack spec cuda@12.9
 -   cuda@12.9.1~allow-unsupported-compilers~dev build_system=generic platform=linux os=rocky8 target=skylake_avx512 
 -       ^coreutils@9.10~gprefix build_system=autotools platform=linux os=rocky8 target=skylake_avx512 %c=gcc@8.5.0
[+]          ^compiler-wrapper@1.0 build_system=generic platform=linux os=rocky8 target=skylake_avx512 
[e]          ^gcc@8.5.0+binutils+bootstrap~graphite+libsanitizer~nvptx~piclibs~profiled~strip build_system=autotools build_type=RelWithDebInfo languages:='c,c++,fortran' platform=linux os=rocky8 target=x86_64 
[+]          ^gcc-runtime@8.5.0 build_system=generic platform=linux os=rocky8 target=skylake_avx512 
[e]          ^glibc@2.28 build_system=autotools platform=linux os=rocky8 target=x86_64 
[+]          ^gmake@4.4.1~guile build_system=generic platform=linux os=rocky8 target=skylake_avx512 %c=gcc@8.5.0
[+]          ^openssl@3.6.1~docs+shared build_system=generic certs=mozilla platform=linux os=rocky8 target=skylake_avx512 %c,cxx=gcc@8.5.0
[+]              ^ca-certificates-mozilla@2025-08-12 build_system=generic platform=linux os=rocky8 target=skylake_avx512 
[+]              ^perl@5.42.0+cpanm+opcode+open+shared+threads build_system=generic platform=linux os=rocky8 target=skylake_avx512 %c=gcc@8.5.0
[+]                  ^berkeley-db@18.1.40+cxx~docs+stl build_system=autotools patches:=26090f4,b231fcc platform=linux os=rocky8 target=skylake_avx512 %c,cxx=gcc@8.5.0
[+]                  ^bzip2@1.0.8~debug~pic+shared build_system=generic platform=linux os=rocky8 target=skylake_avx512 %c=gcc@8.5.0
[+]                      ^diffutils@3.12 build_system=autotools platform=linux os=rocky8 target=skylake_avx512 %c=gcc@8.5.0
[+]                  ^gdbm@1.26 build_system=autotools platform=linux os=rocky8 target=skylake_avx512 %c=gcc@8.5.0
[+]                      ^readline@8.3 build_system=autotools patches:=21f0a03 platform=linux os=rocky8 target=skylake_avx512 %c=gcc@8.5.0
[+]                          ^ncurses@6.6~symlinks+termlib abi=none build_system=autotools patches:=7a351bc platform=linux os=rocky8 target=skylake_avx512 %c,cxx=gcc@8.5.0
 -       ^gzip@1.14 build_system=autotools platform=linux os=rocky8 target=skylake_avx512 %c=gcc@8.5.0
 -       ^libxml2@2.13.9~http+pic~python+shared build_system=autotools platform=linux os=rocky8 target=skylake_avx512 %c=gcc@8.5.0
[+]          ^libiconv@1.18 build_system=autotools libs:=shared,static platform=linux os=rocky8 target=skylake_avx512 %c=gcc@8.5.0
[+]          ^pkgconf@2.5.1 build_system=autotools platform=linux os=rocky8 target=skylake_avx512 %c=gcc@8.5.0
[+]          ^xz@5.8.2~pic build_system=autotools libs:=shared,static platform=linux os=rocky8 target=skylake_avx512 %c=clang@20.1.8
[e]              ^llvm@20.1.8+clang~cuda~flang~gold+libomptarget~libomptarget_debug~link_llvm_dylib+lld+lldb+llvm_dylib+lua~mlir+offload+polly~python~split_dwarf~utils~z3~zstd build_system=cmake build_type=Release compiler-rt=runtime generator=ninja libcxx=runtime libunwind=runtime openmp=runtime shlib_symbol_version=none targets:=aarch64,amdgpu,nvptx,x86 version_suffix=none platform=linux os=rocky8 target=x86_64 
[+]          ^zlib-ng@2.3.3+compat+new_strategies+opt+pic+shared build_system=autotools platform=linux os=rocky8 target=skylake_avx512 %c,cxx=gcc@8.5.0


real	0m37.097s
user	0m20.070s
sys	0m3.038s
```
```bash
(base) [u6059911@notchpeak2:cuda_test]$ time spack spec --fresh --long cuda@12.9
 -   oy27i5t  cuda@12.9.1~allow-unsupported-compilers~dev build_system=generic platform=linux os=rocky8 target=skylake_avx512 
 -   fxxskjy      ^coreutils@9.10~gprefix build_system=autotools platform=linux os=rocky8 target=skylake_avx512 %c=gcc@15.1.0
[+]  7ixievn          ^compiler-wrapper@1.0 build_system=generic platform=linux os=rocky8 target=skylake_avx512 
[e]  suikk5o          ^gcc@15.1.0+binutils+bootstrap~graphite+libsanitizer~mold~nvptx~piclibs~profiled~strip build_system=autotools build_type=RelWithDebInfo languages:='c,c++,fortran' platform=linux os=rocky8 target=x86_64 
[+]  ohrizkr          ^gcc-runtime@15.1.0 build_system=generic platform=linux os=rocky8 target=skylake_avx512 
[e]  vuczjrb          ^glibc@2.28 build_system=autotools platform=linux os=rocky8 target=x86_64 
 -   nr6b2f5          ^gmake@4.4.1~guile build_system=generic platform=linux os=rocky8 target=skylake_avx512 %c=gcc@15.1.0
 -   6sc6u4g          ^openssl@3.6.1~docs+shared build_system=generic certs=mozilla platform=linux os=rocky8 target=skylake_avx512 %c,cxx=gcc@15.1.0
[+]  bapfsen              ^ca-certificates-mozilla@2025-08-12 build_system=generic platform=linux os=rocky8 target=skylake_avx512 
 -   j5ee4ju              ^perl@5.42.0+cpanm+opcode+open+shared+threads build_system=generic platform=linux os=rocky8 target=skylake_avx512 %c=gcc@15.1.0
 -   2uufpmn                  ^berkeley-db@18.1.40+cxx~docs+stl build_system=autotools patches:=26090f4,b231fcc platform=linux os=rocky8 target=skylake_avx512 %c,cxx=gcc@15.1.0
 -   o5o2q6i                  ^bzip2@1.0.8~debug~pic+shared build_system=generic platform=linux os=rocky8 target=skylake_avx512 %c=gcc@15.1.0
 -   fuverkt                      ^diffutils@3.12 build_system=autotools platform=linux os=rocky8 target=skylake_avx512 %c=gcc@15.1.0
 -   x27q2a2                  ^gdbm@1.26 build_system=autotools platform=linux os=rocky8 target=skylake_avx512 %c=gcc@15.1.0
 -   roex5yj                      ^readline@8.3 build_system=autotools patches:=21f0a03 platform=linux os=rocky8 target=skylake_avx512 %c=gcc@15.1.0
 -   ni3mrdn                          ^ncurses@6.6~symlinks+termlib abi=none build_system=autotools patches:=7a351bc platform=linux os=rocky8 target=skylake_avx512 %c,cxx=gcc@15.1.0
 -   mn4l7zc      ^gzip@1.14 build_system=autotools platform=linux os=rocky8 target=skylake_avx512 %c=gcc@15.1.0
 -   3ytdtc7      ^libxml2@2.13.9~http+pic~python+shared build_system=autotools platform=linux os=rocky8 target=skylake_avx512 %c=gcc@15.1.0
 -   u7kvzoz          ^libiconv@1.18 build_system=autotools libs:=shared,static platform=linux os=rocky8 target=skylake_avx512 %c=gcc@15.1.0
 -   rz6uaud          ^pkgconf@2.5.1 build_system=autotools platform=linux os=rocky8 target=skylake_avx512 %c=gcc@15.1.0
 -   cem6gdg          ^xz@5.8.2~pic build_system=autotools libs:=shared,static platform=linux os=rocky8 target=skylake_avx512 %c=gcc@15.1.0
 -   mwvlhnt          ^zlib-ng@2.3.3+compat+new_strategies+opt+pic+shared build_system=autotools platform=linux os=rocky8 target=skylake_avx512 %c,cxx=gcc@15.1.0


real	0m26.270s
user	0m18.896s
sys	0m1.883s
```
```bas
(base) [u6059911@notchpeak2:cuda_test]$ time spack mirror create -d mirror cuda@12.9
==> Adding package cuda@12.9.1 to mirror
==> Using cached archive: /scratch/general/vast/u6059911/spack/var/spack/cache/_source-cache/archive/0f/0f6d806ddd87230d2adbe8a6006a9d20144fdbda9de2d6acc677daa5d036417a
==> Archive stats:
    0    already present
    1    added
    0    failed to fetch.

real	1m19.831s
user	0m52.153s
sys	0m12.895s
```
```bash
(base) [u6059911@notchpeak2:cuda_test]$ spack mirror create -d mirror --dependencies cuda@12.9
==> Skipping gcc@8.5.0+binutils+bootstrap~graphite+libsanitizer~nvptx~piclibs~profiled~strip build_system=autotools build_type=RelWithDebInfo languages:='c,c++,fortran' platform=linux os=rocky8 target=x86_64/nvz3nps as it is an external spec.
==> Skipping glibc@2.28 build_system=autotools platform=linux os=rocky8 target=x86_64/vuczjrb as it is an external spec.
==> Skipping llvm@20.1.8+clang~cuda~flang~gold+libomptarget~libomptarget_debug~link_llvm_dylib+lld+lldb+llvm_dylib+lua~mlir+offload+polly~python~split_dwarf~utils~z3~zstd build_system=cmake build_type=Release compiler-rt=runtime generator=ninja libcxx=runtime libunwind=runtime openmp=runtime shlib_symbol_version=none targets:=aarch64,amdgpu,nvptx,x86 version_suffix=none platform=linux os=rocky8 target=x86_64/k4nwhhu as it is an external spec.
==> Adding package berkeley-db@18.1.40 to mirror
    [100%]   30.76 MB @   58.1 MB/s
==> Adding package bzip2@1.0.8 to mirror
    [100%]  810.03 KB @   11.5 MB/s
==> Adding package ca-certificates-mozilla@2025-08-12 to mirror
    [100%]  227.92 KB @    5.9 MB/s
==> Adding package compiler-wrapper@1.0 to mirror
    [100%]   30.13 KB @    2.2 MB/s
==> Adding package coreutils@9.10 to mirror
    [100%]    6.51 MB @   38.8 MB/s
==> Adding package cuda@12.9.1 to mirror
==> Adding package diffutils@3.12 to mirror
    [100%]    1.94 MB @   22.5 MB/s
==> Adding package gcc-runtime@8.5.0 to mirror
==> Adding package gdbm@1.26 to mirror
    [100%]    1.23 MB @   17.3 MB/s
==> Adding package gmake@4.4.1 to mirror
    [100%]    2.35 MB @   24.8 MB/s
==> Adding package gzip@1.14 to mirror
    [100%]    1.37 MB @   18.5 MB/s
==> Adding package libiconv@1.18 to mirror
    [100%]    5.82 MB @   49.9 MB/s
==> Adding package libxml2@2.13.9 to mirror
    [100%]    2.43 MB @   19.1 MB/s
    [100%]  638.94 KB @   10.6 MB/s
==> Adding package ncurses@6.6 to mirror
    [100%]    3.79 MB @   34.6 MB/s
==> Adding package openssl@3.6.1 to mirror
    [100%]   54.89 MB @   42.7 MB/s
==> Adding package perl@5.42.0 to mirror
    [100%]   20.85 MB @   51.1 MB/s
==> Adding package pkgconf@2.5.1 to mirror
    [100%]  328.06 KB @    7.5 MB/s
==> Adding package readline@8.3 to mirror
    [100%]    3.42 MB @   29.5 MB/s
    [100%]    1.85 KB @  467.4 KB/s
==> Adding package xz@5.8.2 to mirror
    [100%]    2.00 MB @   21.7 MB/s
==> Adding package zlib-ng@2.3.3 to mirror
    [100%]    2.45 MB @   14.6 MB/s
==> Archive stats:
    1    already present
    18   added
    0    failed to fetch.
```