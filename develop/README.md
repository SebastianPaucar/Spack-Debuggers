# Spack staging and Debugging model with `spack develop` 

Let's attempt to run `spack develop`:

```bash
(base) [u6059911@notchpeak1:~]$ cd /scratch/general/vast/u6059911/gsoc/gsoc_spack/
(base) [u6059911@notchpeak1:gsoc_spack]$ spack develop fmt@12.1.0
==> Error: `spack develop` requires an environment
  activate an environment first:
      spack env activate ENV
  or use:
      spack -e ENV develop ...
```

We see `spack develop` is not a standalone build command. It is an **environment-scoped operation**. Let's see it:

```bash
(base) [u6059911@notchpeak1:gsoc_spack]$ spack env create fmt_env
==> Created environment fmt_env in: /scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env
==> Activate with: spack env activate fmt_env
(base) [u6059911@notchpeak1:gsoc_spack]$ spack env activate fmt_env
(base) [u6059911@notchpeak1:gsoc_spack]$ spack develop fmt@12.1.0
==> Cloning source code for fmt@=12.1.0
==> Using cached archive: /scratch/general/vast/u6059911/spack/var/spack/cache/_source-cache/archive/69/695fd197fa5aff8fc67b5f2bbc110490a875cdf7a41686ac8512fb480fa8ada7.zip
```

Note that `spack develop` uses a cached archive inside `/scratch/general/vast/u6059911/spack/var/spack/cache/_source-cache/` to clone the package source tree. We find `/scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env` is the `fmt_env` environment path:

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

Note that one can modify the environment configuration (`spack.yaml`) by adding a `develop:` entry. Since `spack develop` binds a package to a persistent source tree inside the environment, it enables stable source paths and reproducible debugging setups accross builds. This means all `develop` workflows must begin from an active environment context:

```bash
(base) [u6059911@notchpeak1:fmt_env]$ spack find -lv fmt
==> Error: No package matches the query: fmt
(base) [u6059911@notchpeak1:fmt_env]$ spack env list
==> 1 environments
    fmt_env
(base) [u6059911@notchpeak1:fmt_env]$ spack env status
==> Using spack.yaml in current directory: /scratch/general/vast/u6059911/spack/var/spack/environments/fmt_env
```

From the `spack find -lv fmt` output, we see `develop` does not imply installation, even though `fmt` appears under `develop:` in `spack.yaml`. `specs: []` means the `fmt_env` does not request any packages to be installed. The `spec: fmt@=12.1.0` entry under `develop:` declares the usage of the `fmt` local source tree instead of fetching from a tarball (it does NOT introduce `fmt` into the dependecy graph). `spack env status` indicates the active environment.

> Spack`s envirionment model insight: `specs` defines what is installed; `develop` defines where the source comes from.

We can verify that `$SPACK_ROOT/var/spack/environments/` contains the full list of Spack environments:

```bash
(base) [u6059911@notchpeak1:fmt_env]$ echo $SPACK_ROOT 
/scratch/general/vast/u6059911/spack
(base) [u6059911@notchpeak1:fmt_env]$ ls $SPACK_ROOT/var/spack/environments/
fmt_env
```

Attempting `install` with no `specs` defined yet in `spack.yaml`: 

```bash
(base) [u6059911@notchpeak1:fmt_env]$ spack install 
==> fmt_env environment has no specs to install
(base) [u6059911@notchpeak1:fmt_env]$ spack location -i fmt
==> Error: Spec 'fmt' matches no installed packages.
```

We verify that Spack only installs packages that appear in the `specs` list (the root of the dependency graph).

> If `specs: []`, so: no DAG, no packages associated with the environment, `spack find` returns nothing.

> DAG: Directed Acyclic Graph. In Spack, a DAG is the full dependency graph of a package specification (`spec`), including all transitive dependencies. When `specs: []`, the DAG is an empty graph: no nodes, no dependencies, nothing to build. So the installation workflow under `spack develop` follow a `specs - DAG - build/install` workflow. Inside an environment, `spack find` only show nodes in the environment's DAG.

> In `spack.yaml`, the `develop:` section only affects nodes already present in the DAG. If `fmt` is not in the DAG, `develop` has no effect.

> Each DAG node is a **fully concretized `spec`**, such as `fmt@12.1.0 %gcc@8.5.0 build_type=Debug arch=linux-skylake_avx512`. Edges represent build, link and run dependencies. **DWARF information is generated per node in the DAG during compilation**, so no node, then no binary and no DWARF, and wrong node (e.g., `buildcache`), then wrong paths in DWARF. DAG is the dependecy graph of `specs`, it is the core internal structure Spack operates on, and everyting (build, install, debug info) depends on it.

Note that the `spack location -i fmt` output suggests there is no previous `fmt` installation, which is not true (there is already a normal build `fmt` installation based on `spack install`). Let's do this:

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

We found a key property of Spack: installed packages are global (per Spack instance), while environments only define views over them. When an environment is active, Spack operates in environment scope, meaning:

* Only packages in the environment’s concretized DAG are visible
* Queries like `spack find` are filtered to the environment

So Spack operates in global scope outside the environment (after `spack env deactivate`), it queries the full installation databese under `$SPACK_ROOT/opt/spack/`, so both `spack find -lv fmt` and `spack location -i /ds5k4qo` returns the previously installed package, regardless of any environment.

> Spack separates `Installation database (global)` and `Environment view (scoped)`. So environments do not “contain” packages, they reference a subset of the global store via their DAG.

> For debugging workflows, that distinction is critical. A package may be installed globally (with DWARF info) or invisible inside an environment. Debugging inside an environment requires that the package belongs to the environment DAG. Otherwise, `spack location` will fail even though binaries exists on disk.

Getting back to `fmt_env` Spack environment:

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
(base) [u6059911@notchpeak1:fmt_env]$ nohup spack install > spack_install_fmt_env-no-debug.log 2>&1 &
```

`spack add fmt@12.1.0` updates the `specs:` section on `spack.yaml` by adding the package (`fmt@12.1.0`). Therefore, `spack add` modifies the DAG roots. Since the `specs:` section defines the root node of the environment’s dependency graph (DAG), `fmt@12.1.0` becomes **elegible to concretization** and included in the environment's build plan. While:

```bash
  develop:
    fmt:
      spec: fmt@=12.1.0
```

Introduces a **source override**, which means that during concretization/build, Spack will use a local source tree instead of fetching a tarball. So the resulting build pipeline becomes `spec - DAG construction - source resolution (overriden by spack develop) - build from local source tree - install into prefix`. On another note:

```bash
concretizer:
  unify: true
```

> `spack add` does NOT build anything (no concretization, compilation, or installation occurs yet). With just `spack add`, DAG is not yet concretized and installed packages are unchanged. It marks the environment as needing concretization (**dirty state:** the declared `specs` have changed, but the DAG has not been resolved yet).

> `spack install` triggers `specs - concretization - DAG - build - install`. **Concretization** resolves compiler, dependencies, variants and architecture. **DAG creation** produces a fully specified graph. **Build + Install** compiles `fmt` and install into its prefix. If one also have the `develop:` section with `fmt`, then the `fmt` added via `spack add` will be built from the local source tree, not from a downloaded tarball. `spack add` adds a node to the **future** DAG.

Enforces a single, globally consistent instance of `fmt` (and its dependencies) across the DAG. `spack install` concretizez the DAG, resolve dependecies, builds `fmt` (from the `develop` source` and installs into `$SPACK_ROOT/opt/spack/`. Let's see it:

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

At this point, the `fmt_env` environment has a non-empty DAG, where `fmt` is built from a controlled source tree (`develop`) and installed into a stable prefix associated with the hash `/nwdarro` (`/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-nwdarroqz7al36bwfriq5ljk5nvt7ttm`). However, since no debug variant (e.g., `build_type=Debug`) is specified, the build will likely be `Release` or `RelWithDebInfo`. Thus DWARF info may be absent. Let's look into it:

```bash
(base) [u6059911@notchpeak1:fmt_env]$ spack location -i /nwdarro
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-nwdarroqz7al36bwfriq5ljk5nvt7ttm
(base) [u6059911@notchpeak1:fmt_env]$ spack location -s /nwdarro
/tmp/u6059911/spack-stage/spack-stage-fmt-12.1.0-nwdarroqz7al36bwfriq5ljk5nvt7ttm
(base) [u6059911@notchpeak1:fmt_env]$ find $(spack location -i /nwdarro) -name "*.a" -o -name "*.so"
/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-nwdarroqz7al36bwfriq5ljk5nvt7ttm/lib64/libfmt.a
```

We retrieve the installation prefix of the concretized `spec` and the build-time workspace staging directory, both identified by the `nwdarro` hash. The `lib64/libfmt.a` output confirms the package was installed in `Release` mode (no `libfmtd.a`).

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
(base) [u6059911@notchpeak1:fmt_env]$ nohup spack concretize --force > spack_concretize_fmt_env.log 2>&1 &
(base) [u6059911@notchpeak1:fmt_env]$ nohup spack install > spack_install_fmt_env-debug.log 2>&1 &
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