# Part 2: Prototype a "Keep-Source" Hook (Includes `source_exporter.py`)

This prototype implements a simplified **Spack post-install hook** that preserves package source files inside the installation prefix for debugging purposes. This is its overall workflow:

![Keep-Source Prototype](https://gist.githubusercontent.com/SebastianPaucar/fc147e781e714ba7337fac546ffb162d/raw/spack_keep_source_hook.png)

## `source_exporter.py`

The following script (`source_exporter.py`):

```bash
(base) [u6059911@notchpeak2:spack_gsoc]$ cat source_exporter.py 
import shutil
import subprocess
from pathlib import Path


def spack_location(flag, pkg):
    return subprocess.check_output(
        ["spack", "location", flag, pkg],
        text=True
    ).strip()

def keep_source(pkgname):

    print("Running keep-source hook for package:", pkgname)
    
    subprocess.run(["spack", "stage", pkgname], check=True)

    build_stage = spack_location("-s", pkgname)
    install_prefix = spack_location("-i", pkgname)

    print("\nBuild stage:", build_stage)
    print("Installation prefix:", install_prefix)
    print("Installation prefix size before build /src transfer:")
    subprocess.run(["du", "-sk", install_prefix], check=True)

    src_root = Path(build_stage) / "spack-src" / "src"
    dst_root = Path(install_prefix) / "share" / pkgname / "src"

    print("\nSource root:", src_root)
    print("Destination directory:", dst_root)

    dst_root.mkdir(parents=True, exist_ok=True)

    extensions = {".h", ".hh", ".cc", ".cpp"}

    for f in src_root.rglob("*"):
        if f.suffix in extensions:
            shutil.copy2(f, dst_root / f.name)

    print("\nSources copied to:", dst_root)

    print("\nRunning size verification:")
    subprocess.run(["bash", "analyze_size.sh", install_prefix, str(dst_root), str(src_root)], check=True)
    
    print("\nCleaning Spack stage directories")
    subprocess.run(["spack", "clean", "--stage"], check=True)
    
if __name__ == "__main__":
    keep_source("fmt")
```

* Stages a package and retrieves its build stage and installation prefix using `spack location`
* Locates the package `src/` directory inside the temporary build tree
* Copies only source files (`.h`, `.hh`, `.cpp`, `.cc`) into `share/<pkgname>/src` inside the installation prefix
* Excludes build artifacts (e.g., `.o` files, `CMakeFiles/` directories) to avoid installation bloat
* Verifies the size impact using `du` to confirm that only the source code is added, not the entire build tree. Particularly, it uses the shell script (`source_exporter_command_shell.sh`):

```bash
#!/bin/bash

PREFIX=$1
DST_SRC=$2
BUILD_SRC=$3

echo "Installation prefix size after /src transfer:"
du -sk "$PREFIX"
echo "Copied sources size:"
du -sk "$DST_SRC"
echo "Original source size in build tree:"
du -sk "$BUILD_SRC"
```

Finally `source_exporter.py` outputs:

```bash
(base) [u6059911@notchpeak2:spack_gsoc]$ python source_exporter.py
Running keep-source hook for package: fmt
==> Using cached archive: /scratch/general/vast/u6059911/spack/var/spack/cache/_source-cache/archive/69/695fd197fa5aff8fc67b5f2bbc110490a875cdf7a41686ac8512fb480fa8ada7.zip
==> Staged fmt in /scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f

Build stage: /scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f
Installation prefix: /scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f
Installation prefix size before build /src transfer:
2578	/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f

Source root: /scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src
Destination directory: /scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/share/fmt/src

Sources copied to: /scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/share/fmt/src

Running size verification:
Installation prefix size after /src transfer:
2595	/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f
Copied sources size:
17	/scratch/general/vast/u6059911/spack/opt/spack/linux-skylake_avx512/fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/share/fmt/src
Original source size in build tree:
17	/scratch/general/vast/u6059911/spack-stage/spack-stage-fmt-12.1.0-ds5k4qopyg3nrexsdz4utbhht5hkj56f/spack-src/src

Cleaning Spack stage directories
==> Removing all temporary build stages

```

Thus, the script verifies the size impact of the operation using `du -sk`. By comparing the size of the installation prefix before and after the copy, and the size of the copied `/src` directory, we can confirm that the prefix only grows by the size of the source files rather than the entire build tree.