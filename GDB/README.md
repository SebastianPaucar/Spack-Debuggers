```bash
(base) [u6059911@notchpeak1:~]$ cd /scratch/general/vast/u6059911/gsoc/gsoc_spack/
(base) [u6059911@notchpeak1:gsoc_spack]$ spack env create debug-test
==> Created environment debug-test in: /scratch/general/vast/u6059911/spack/var/spack/environments/debug-test
==> Activate with: spack env activate debug-test
(base) [u6059911@notchpeak1:gsoc_spack]$ spack env activate debug-test
(base) [u6059911@notchpeak1:gsoc_spack]$ 
(base) [u6059911@notchpeak1:gsoc_spack]$ spack add zlib cflags="-g -O0"
==> Adding zlib cflags='-g -O0' to environment debug-test
(base) [u6059911@notchpeak1:gsoc_spack]$ cd  /scratch/general/vast/u6059911/spack/var/spack/environments/debug-test
(base) [u6059911@notchpeak1:debug-test]$ ls
spack.yaml
(base) [u6059911@notchpeak1:debug-test]$ cat spack.yaml 
# This is a Spack Environment file.
#
# It describes a set of packages to be installed, along with
# configuration settings.
spack:
  # add package specs to the `specs` list
  specs:
  - zlib cflags='-g -O0'
  view: true
  concretizer:
    unify: true
(base) [u6059911@notchpeak1:debug-test]$ spack install
==> Concretized 1 spec
 -   hd6a3zw  zlib@1.3.2 cflags='-g -O0' +optimize+pic+shared build_system=makefile platform=linux os=rocky8 target=skylake_avx512 %c,cxx=gcc@8.5.0
[+]  7ixievn      ^compiler-wrapper@1.0 build_system=generic platform=linux os=rocky8 target=skylake_avx512 
[e]  nvz3nps      ^gcc@8.5.0+binutils+bootstrap~graphite+libsanitizer~nvptx~piclibs~profiled~strip build_system=autotools build_type=RelWithDebInfo languages:='c,c++,fortran' platform=linux os=rocky8 target=x86_64 
[+]  3auvped      ^gcc-runtime@8.5.0 build_system=generic platform=linux os=rocky8 target=skylake_avx512 
[e]  vuczjrb      ^glibc@2.28 build_system=autotools platform=linux os=rocky8 target=x86_64 
[+]  fwmpqge      ^gmake@4.4.1~guile build_system=generic platform=linux os=rocky8 target=skylake_avx512 %c=gcc@8.5.0
[+] hd6a3zw zlib@1.3.2 /scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf (18s)
==> Updating view at /scratch/general/vast/u6059911/spack/var/spack/environments/debug-test/.spack-env/view
(base) [u6059911@notchpeak1:debug-test]$ spack location -i zlib
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf
(base) [u6059911@notchpeak1:debug-test]$ find $(spack location -i zlib) -name "*.so*"
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/lib/libz.so
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/lib/libz.so.1
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/lib/libz.so.1.3.2
```

```bash
(base) [u6059911@notchpeak1:debug-test]$ gdb $(spack location -i zlib)/lib/libz.so
GNU gdb (GDB) Rocky Linux 8.2-20.el8.0.1
Copyright (C) 2018 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-redhat-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from /scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/lib/libz.so...done.
(gdb) info sources
Source files for which symbols have been read in:



Source files for which symbols will be read in on demand:

/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src/gzwrite.c, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src/gzread.c, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src/gzlib.c, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src/gzclose.c, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src/uncompr.c, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src/compress.c, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src/zutil.c, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src/trees.c, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src/inftrees.c, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src/inflate.c, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src/inffast.c, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src/infback.c, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src/deflate.c, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src/crc32.c, 
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src/adler32.c
(gdb) list adler32.c:1
1	adler32.c: No such file or directory.
(gdb) info source
Current source file is adler32.c
Compilation directory is /scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src
Source language is c.
Producer is GNU C17 8.5.0 20210514 (Red Hat 8.5.0-28) -march=skylake-avx512 -mtune=skylake-avx512 -g -O2 -O0 -fPIC.
Compiled with DWARF 2 debugging format.
Does not include preprocessor macro info.
(gdb) set substitute-path \
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf/spack-src \
/scratch/general/vast/u6059911/spack/var/spack/environments/debug-test/debugsrc/zlib
(gdb) list adler32.c:1
warning: Source file is more recent than executable.
1	/* adler32.c -- compute the Adler-32 checksum of a data stream
2	 * Copyright (C) 1995-2011, 2016 Mark Adler
3	 * For conditions of distribution and use, see copyright notice in zlib.h
4	 */
5	
6	/* @(#) $Id$ */
7	
8	#include "zutil.h"
9	
10	#define BASE 65521U     /* largest prime smaller than 65536 */
```

```bash
(base) [u6059911@notchpeak1:zlib]$ ldd ./a.out
	linux-vdso.so.1 (0x00007ffe59dda000)
	libz.so.1 => /lib64/libz.so.1 (0x0000145901bde000)
	libc.so.6 => /lib64/libc.so.6 (0x0000145901808000)
	/lib64/ld-linux-x86-64.so.2 (0x0000145901df6000)

(base) [u6059911@notchpeak1:zlib]$ LD_LIBRARY_PATH=$(spack location -i zlib)/lib:$LD_LIBRARY_PATH gdb ./a.out
GNU gdb (GDB) Rocky Linux 8.2-20.el8.0.1
Copyright (C) 2018 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-redhat-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from ./a.out...done.
(gdb) run
Starting program: /scratch/general/vast/u6059911/spack/var/spack/environments/debug-test/debugsrc/zlib/a.out 
1
[Inferior 1 (process 57326) exited normally]
Missing separate debuginfos, use: yum debuginfo-install glibc-2.28-251.el8_10.27.x86_64
```
```bash
(base) [u6059911@notchpeak1:~]$ cd /scratch/general/vast/u6059911/spack/var/spack/environments/debug-test
(base) [u6059911@notchpeak1:debug-test]$ spack stage zlib
==> Using cached archive: /scratch/general/vast/u6059911/spack/var/spack/cache/_source-cache/archive/bb/bb329a0a2cd0274d05519d61c667c062e06990d72e125ee2dfa8de64f0119d16.tar.gz
==> Staged zlib in /scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf
(base) [u6059911@notchpeak1:debug-test]$ spack location -s zlib
/scratch/general/vast/u6059911/spack-stage/spack-stage-zlib-1.3.2-hd6a3zwxhzlmn24wukav3ktr6dabs2rf
(base) [u6059911@notchpeak1:debug-test]$ mkdir -p debugsrc
(base) [u6059911@notchpeak1:debug-test]$ cp -r $(spack location -s zlib)/spack-src debugsrc/zlib
(base) [u6059911@notchpeak1:debug-test]$ cd debugsrc/zlib/
(base) [u6059911@notchpeak1:zlib]$ pwd
/scratch/general/vast/u6059911/spack/var/spack/environments/debug-test/debugsrc/zlib
```
```bash
(base) [u6059911@notchpeak1:zlib]$ emacs debug_zlib_test.c
(base) [u6059911@notchpeak1:zlib]$ cat debug_zlib_test.c
#include <zlib.h>
#include <stdio.h>

int main() {
    unsigned long adler = adler32(0L, Z_NULL, 0);
    printf("%lu\n", adler);
    return 0;
}
(base) [u6059911@notchpeak1:zlib]$ gcc -g -O0 debug_zlib_test.c -I$(spack location -i zlib)/include -L$(spack location -i zlib)/lib -lz
(base) [u6059911@notchpeak1:zlib]$ ls
adler32.c    ChangeLog       contrib            deflate.c  FAQ        gzread.c   inffast.c   inflate.h   Makefile      msdos   README-cmake.md  trees.h    zconf.h     zlibConfig.cmake.in  zlib.pc.in
amiga        CMakeLists.txt  crc32.c            deflate.h  gzclose.c  gzwrite.c  inffast.h   inftrees.c  Makefile.in   os400   test             uncompr.c  zconf.h.in  zlib.h               zutil.c
a.out        compress.c      crc32.h            doc        gzguts.h   INDEX      inffixed.h  inftrees.h  make_vms.com  qnx     treebuild.xml    watcom     zlib.3      zlib.map             zutil.h
BUILD.bazel  configure       debug_zlib_test.c  examples   gzlib.c    infback.c  inflate.c   LICENSE     MODULE.bazel  README  trees.c          win32      zlib.3.pdf  zlib.pc.cmakein
(base) [u6059911@notchpeak1:zlib]$ gdb ./a.out
GNU gdb (GDB) Rocky Linux 8.2-20.el8.0.1
Copyright (C) 2018 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-redhat-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from ./a.out...done.
(gdb) run
Starting program: /scratch/general/vast/u6059911/spack/var/spack/environments/debug-test/debugsrc/zlib/a.out 
1
[Inferior 1 (process 41762) exited normally]
Missing separate debuginfos, use: yum debuginfo-install glibc-2.28-251.el8_10.27.x86_64 zlib-1.2.11-26.el8.x86_64
```