```bash
(base) [u6059911@notchpeak1:~]$ cd /scratch/general/vast/u6059911/gsoc/gsoc_spack/
(base) [u6059911@notchpeak1:gsoc_spack]$ spack develop fmt@12.1.0
==> Error: `spack develop` requires an environment
  activate an environment first:
      spack env activate ENV
  or use:
      spack -e ENV develop ...
```

```bash
(base) [u6059911@notchpeak1:gsoc_spack]$ spack env create fmt_env
==> Created environment fmt_env in: /scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env
==> Activate with: spack env activate fmt_env
(base) [u6059911@notchpeak1:gsoc_spack]$ spack env activate fmt_env
(base) [u6059911@notchpeak1:gsoc_spack]$ spack develop fmt@12.1.0
==> Cloning source code for fmt@=12.1.0
==> Using cached archive: /scratch/general/vast/u6059911/spack/var/spack/cache/_source-cache/archive/69/695fd197fa5aff8fc67b5f2bbc110490a875cdf7a41686ac8512fb480fa8ada7.zip
```

```bash
(base) [u6059911@notchpeak1:gsoc_spack]$ cd /scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env
(base) [u6059911@notchpeak1:fmt_env]$ ls
fmt  spack.yaml
(base) [u6059911@notchpeak1:fmt_env]$ cat spack.yaml 
# This is a Spack Environment file.
#
# It describes a set of packages to be installed, along with
# configuration settings.
spack:
  # add package specs to the `specs` list
  specs: []
  view: true
  concretizer:
    unify: true
  develop:
    fmt:
      spec: fmt@=12.1.0
```

```bash
(base) [u6059911@notchpeak1:fmt_env]$ spack find -lv fmt
==> Error: No package matches the query: fmt
(base) [u6059911@notchpeak1:fmt_env]$ spack env list
==> 1 environments
    fmt_env
(base) [u6059911@notchpeak1:fmt_env]$ spack env status
==> Using spack.yaml in current directory: /scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env
```

```bash
(base) [u6059911@notchpeak1:fmt_env]$ echo $SPACK_ROOT 
/scratch/general/vast/u6059911/spack
(base) [u6059911@notchpeak1:fmt_env]$ ls $SPACK_ROOT/var/spack/environments/
fmt_env
```

```bash
(base) [u6059911@notchpeak1:fmt_env]$ spack install
==> fmt_env environment has no specs to install
(base) [u6059911@notchpeak1:fmt_env]$ spack location -i fmt
==> Error: Spec 'fmt' matches no installed packages.
```

```bash
(base) [u6059911@notchpeak1:fmt_env]$ spack env deactivate
(base) [u6059911@notchpeak1:fmt_env]$ spack env status
==> No active environment
(base) [u6059911@notchpeak1:fmt_env]$ spack find -lv fmt
-- linux-rocky8-skylake_avx512 / %c,cxx=gcc@8.5.0 ---------------
ds5k4qo fmt@12.1.0~ipo+pic~shared build_system=cmake build_type=Debug cxxstd=11 generator=make
==> 1 installed package
(base) [u6059911@notchpeak1:fmt_env]$ spack location -i /ds5k4qo
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f
```

```bash
(base) [u6059911@notchpeak1:fmt_env]$ spack env activate fmt_env
(base) [u6059911@notchpeak1:fmt_env]$ spack add fmt@12.1.0
==> Adding fmt@12.1.0 to environment fmt_env
(base) [u6059911@notchpeak1:fmt_env]$ cat spack.yaml 
# This is a Spack Environment file.
#
# It describes a set of packages to be installed, along with
# configuration settings.
spack:
  # add package specs to the `specs` list
  specs:
  - fmt@12.1.0
  view: true
  concretizer:
    unify: true
  develop:
    fmt:
      spec: fmt@=12.1.0
(base) [u6059911@notchpeak1:fmt_env]$ spack install
```

```bash
(base) [u6059911@notchpeak1:fmt_env]$ spack location -i fmt
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-nwdarroqz7al36bwfriq5ljk5nvt7ttm
(base) [u6059911@notchpeak1:fmt_env]$ spack find -lv fmt
==> In environment fmt_env (1 root spec)
[+] nwdarro fmt@12.1.0

-- linux-rocky8-skylake_avx512 / %c,cxx=gcc@8.5.0 ---------------
nwdarro fmt@12.1.0~ipo+pic~shared build_system=cmake build_type=Release cxxstd=11 dev_path=/scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env/fmt generator=make
==> 1 installed package
==> 0 concretized packages to be installed (show with `spack find -c`)
```

```bash
(base) [u6059911@notchpeak1:fmt_env]$ spack location -i /nwdarro
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-nwdarroqz7al36bwfriq5ljk5nvt7ttm
(base) [u6059911@notchpeak1:fmt_env]$ spack location -s /nwdarro
/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-nwdarroqz7al36bwfriq5ljk5nvt7ttm
(base) [u6059911@notchpeak1:fmt_env]$ find $(spack location -i /nwdarro) -name "*.a" -o -name "*.so"
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-nwdarroqz7al36bwfriq5ljk5nvt7ttm/lib64/libfmt.a
```

```bash
(base) [u6059911@notchpeak1:fmt_env]$ spack add fmt@12.1.0 build_type=Debug
==> Adding fmt@12.1.0 build_type=Debug to environment fmt_env
(base) [u6059911@notchpeak1:fmt_env]$ spack install --fresh
==> Error: Spack concretizer internal error. Please submit a bug report at https://github.com/spack/spack and include the command and environment if applicable.
    [fmt@12.1.0 build_type=Debug, fmt@12.1.0/nwdarroqz7al36bwfriq5ljk5nvt7ttm] is unsatisfiable. Couldn't concretize without changing the existing environment. If you are ok with changing it, try `spack concretize --force`. You could consider setting `concretizer:unify` to `when_possible` or `false` to allow multiple versions of some packages.
```

```bash
(base) [u6059911@notchpeak1:fmt_env]$ cat spack.yaml
# This is a Spack Environment file.
#
# It describes a set of packages to be installed, along with
# configuration settings.
spack:
  # add package specs to the `specs` list
  specs:
  - fmt@12.1.0
  - fmt@12.1.0 build_type=Debug
  view: true
  concretizer:
    unify: true
  develop:
    fmt:
      spec: fmt@=12.1.0
(base) [u6059911@notchpeak1:fmt_env]$ emacs spack.yaml
(base) [u6059911@notchpeak1:fmt_env]$ cat spack.yaml
# This is a Spack Environment file.
#
# It describes a set of packages to be installed, along with
# configuration settings.
spack:
  # add package specs to the `specs` list
  specs:
  - fmt@12.1.0 build_type=Debug
  view: true
  concretizer:
    unify: true
  develop:
    fmt:
      spec: fmt@=12.1.0
```

```bash
(base) [u6059911@notchpeak1:fmt_env]$ spack concretize --force
(base) [u6059911@notchpeak1:fmt_env]$ spack install
(base) [u6059911@notchpeak1:fmt_env]$ spack find -lv fmt
==> In environment fmt_env (1 root spec)
[+] oi7yimm fmt@12.1.0 build_type=Debug

-- linux-rocky8-skylake_avx512 / %c,cxx=gcc@8.5.0 ---------------
oi7yimm fmt@12.1.0~ipo+pic~shared build_system=cmake build_type=Debug cxxstd=11 dev_path=/scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env/fmt generator=make
==> 1 installed package
==> 0 concretized packages to be installed (show with `spack find -c`)
```

```bash
(base) [u6059911@notchpeak1:fmt_env]$ spack location -i /oi7yimm
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-oi7yimml7gcetixavsek7muxighkfumh
(base) [u6059911@notchpeak1:fmt_env]$ spack location -s /oi7yimm
/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-oi7yimml7gcetixavsek7muxighkfumh
(base) [u6059911@notchpeak1:fmt_env]$ ls /tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-oi7yimml7gcetixavsek7muxighkfumh
spack-build-01-cmake-out.txt  spack-build-03-install-out.txt  spack-build-env.txt  spack-build-out.txt
spack-build-02-build-out.txt  spack-build-env-mods.txt        spack-build-oi7yimm  spack-configure-args.txt
```

```bash
(base) [u6059911@notchpeak1:fmt_env]$ find $(spack location -i /oi7yimm) -name "*.a" -o -name "*.so"
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-oi7yimml7gcetixavsek7muxighkfumh/lib64/libfmtd.a
(base) [u6059911@notchpeak1:fmt_env]$ readelf --debug-dump=info $(spack location -i /oi7yimm)/lib64/libfmtd.a | grep DW_AT_comp_dir
    <16>   DW_AT_comp_dir    : (indirect string, offset: 0x3110c): /tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-oi7yimml7gcetixavsek7muxighkfumh/spack-build-oi7yimm
    <16>   DW_AT_comp_dir    : (indirect string, offset: 0x95c7): /tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-oi7yimml7gcetixavsek7muxighkfumh/spack-build-oi7yimm
(base) [u6059911@notchpeak1:fmt_env]$ readelf --debug-dump=info $(spack location -i /oi7yimm)/lib64/libfmtd.a | grep DW_AT_name | grep '/' 
    <12>   DW_AT_name        : (indirect string, offset: 0x317c0): /scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env/fmt/src/format.cc
    <12>   DW_AT_name        : (indirect string, offset: 0xda77): /scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env/fmt/src/os.cc
```

```bash
(base) [u6059911@notchpeak1:fmt_env]$ ls /scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env/fmt/
build-linux-rocky8-skylake_avx512-nwdarro  ChangeLog.md    CONTRIBUTING.md  doc-html        include  README.md  support
build-linux-rocky8-skylake_avx512-oi7yimm  CMakeLists.txt  doc              fmt-12.1.0.zip  LICENSE  src        test
(base) [u6059911@notchpeak1:fmt_env]$ rm fmt/build-linux-rocky8-skylake_avx512-nwdarro
```

```bash
(base) [u6059911@notchpeak1:fmt_env]$ readelf --debug-dump=decodedline $(spack location -i /oi7yimm)/lib64/libfmtd.a | grep '/' | awk '!seen[$0]++'
File: /scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-oi7yimml7gcetixavsek7muxighkfumh/lib64/libfmtd.a(format.cc.o)
CU: /usr/include/c++/8/bits/exception.h:
/usr/include/c++/8/new:
/usr/include/c++/8/limits:
/usr/include/c++/8/cmath:
/scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env/fmt/include/fmt/base.h:
/usr/include/c++/8/bits/char_traits.h:
/usr/include/c++/8/system_error:
/scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env/fmt/include/fmt/format.h:
/usr/include/c++/8/type_traits:
/usr/include/c++/8/bits/locale_classes.h:
/usr/include/c++/8/x86_64-redhat-linux/bits/ctype_inline.h:
/scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env/fmt/include/fmt/format-inl.h:
/scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env/fmt/src/format.cc:
/usr/include/c++/8/bits/basic_string.h:
/usr/include/c++/8/bits/move.h:
/usr/include/c++/8/bits/locale_classes.tcc:
/usr/include/c++/8/bits/locale_facets.h:
/usr/include/c++/8/bits/alloc_traits.h:
/usr/include/c++/8/bits/stl_iterator.h:
File: /scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-oi7yimml7gcetixavsek7muxighkfumh/lib64/libfmtd.a(os.cc.o)
/scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env/fmt/include/fmt/os.h:
/scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env/fmt/src/os.cc:
```