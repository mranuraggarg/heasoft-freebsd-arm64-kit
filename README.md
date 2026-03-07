# HEASoft 6.36 FreeBSD ARM64 Porting Kit

This repo is a **small companion kit** for building HEASoft 6.36 on FreeBSD 15 arm64 (including Apple Silicon VM workflows).

It contains:
- curated patch series (`patches/0005..0028`)
- a working environment file (`heasoft_env.sh`)
- a captured FreeBSD install tree snapshot (`heasoft_dir_structure.freebsd.txt`)

It intentionally does **not** contain the full HEASoft source tree.

## Prerequisites (FreeBSD host)
- base tools: `git`, `gmake`, `perl`, `python3`, `pkgconf`
- compilers: `gcc14`, `gfortran14`
- runtime libs commonly needed by HEASoft modules
- optional but recommended for XSPEC prompt: `tclreadline` package

## Quick usage
1. Get official HEASoft source (`heasoft-6.36`) from HEASARC.
2. Copy this kit next to source, or clone inside source root.
3. Source env file:

```sh
source ./heasoft_env.sh
```

4. Apply patch series:

```sh
./scripts/apply_patches.sh /path/to/heasoft-6.36
```

5. Configure/build HEASoft as usual (from HEASoft docs).

## XSPEC readline prompt fix (system tclreadline)
If XSPEC falls back to plain `%` prompt, set:

```sh
export TCLLIBPATH="/usr/local/lib/tclreadline2.4.0 ${TCLLIBPATH:-}"
unset TCLRL_LIBDIR
```

To persist, add the above lines to your shell rc or keep in `heasoft_env.sh`.

## heasoftpy notes
`heasoftpy` import may require Python packages:

```sh
sudo pkg install py311-astropy py311-numpy py311-scipy py311-matplotlib
```

## Included patches
See `patches/` for full list (0005 to 0028).

## License

This repository contains patches and build scripts written by the author
and is released under the BSD 3-Clause License.

HEASoft itself is developed and distributed by NASA HEASARC and is
licensed under its own license terms. Users must download the original
HEASoft source from:

https://heasarc.gsfc.nasa.gov/lheasoft/

This repository does not redistribute HEASoft source code.
