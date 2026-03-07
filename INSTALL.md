# Installation Guide

This document describes how the HEASoft FreeBSD ARM64 port was built and tested.

The reference environment used for testing is described below.

## Host System

- macOS 26.3.1
- UTM Version 4.6.4 (107)

UTM download:

https://mac.getutm.app/

## Virtual Machine

FreeBSD 15.0-RELEASE ARM64

ISO used:

https://download.freebsd.org/releases/arm64/aarch64/ISO-IMAGES/15.0/FreeBSD-15.0-RELEASE-arm64-aarch64-bootonly.iso

Other installation media such as `dvd1` or `disc1` can also be used.

The boot-only image was used in the reference installation.

## FreeBSD installation

Install FreeBSD normally inside the UTM VM.

After installation, update packages:

```sh
pkg update
pkg upgrade
```

Install required build tools:

```sh
pkg install git gmake gcc14 gfortran14 perl python3 pkgconf tcl86 tk86 tclreadline
```

Install recommended runtime/UI dependencies (especially for XSPEC/Tk/X11 workflows):

```sh
pkg install xorg
```

Optional Python packages for `heasoftpy` workflows:

```sh
pkg install py311-astropy py311-numpy py311-scipy py311-matplotlib
```

## Download HEASoft source

From inside the VM, download HEASoft 6.36 source.

Example:

```sh
fetch https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft6.36/heasoft-6.36src.tar.gz
```

The source archive including XSPEC models is approximately **4.3 GB**.

Interactive download page:

https://heasarc.gsfc.nasa.gov/docs/software/lheasoft/download.html

All components were selected during the reference build.

Extract the archive:

```sh
tar -xvf heasoft-6.36src.tar.gz
```

## Apply FreeBSD ARM64 patch kit

Clone the porting kit repository:

```sh
git clone https://github.com/mranuraggarg/heasoft-freebsd-arm64-kit.git
```

Source the environment:

```sh
source ./heasoft_env.sh
```

Apply patches:

```sh
./scripts/apply_patches.sh /path/to/heasoft-6.36
```

## Build HEASoft

Follow the standard HEASoft build procedure after patch application.

## Validation

Use:

- `validation.md`
- `examples/test_heasoft.sh`
