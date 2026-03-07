

---
title: "Porting HEASoft to FreeBSD ARM64: A Reproducible Build Framework"
authors:
  - name: Anurag Garg
    orcid: 0000-0001-9448-3960
    affiliation: Ministry of Education, UAE
affiliations:
  - name: Independent Researcher
    index: 1
date: 7 Mar 2026
bibliography: paper.bib
---

# Summary

HEASoft is a widely used software suite developed by NASA's High Energy Astrophysics Science Archive Research Center (HEASARC) for the reduction and analysis of high‑energy astrophysical data. The package includes widely used analysis tools such as **FTOOLS** and the **XSPEC** spectral fitting environment. Although HEASoft officially supports Linux and macOS platforms, building the software on other Unix‑like operating systems often requires additional configuration and platform‑specific adjustments.

This project provides a reproducible framework for compiling and running **HEASoft 6.36 on FreeBSD ARM64 systems**, including Apple Silicon virtualization environments. The repository contains a curated patch series, environment configuration scripts, and documentation that resolve platform‑specific build issues encountered during compilation.

The resulting workflow demonstrates that HEASoft can operate reliably on FreeBSD ARM64 while preserving the original upstream source distribution. The framework expands accessibility of the HEASoft ecosystem to an additional Unix platform and architecture while maintaining reproducibility and transparency in the build process.

# Statement of Need

HEASoft is an essential component of many high‑energy astrophysics data analysis pipelines. Tools such as XSPEC are widely used for spectral analysis of X‑ray observations from missions including *Chandra*, *XMM‑Newton*, *Swift*, and *NuSTAR* \citep{arnaud1996xspec}.

While HEASoft is designed to be portable, official build environments primarily target Linux and macOS. As a result, compiling HEASoft on other Unix‑like systems may require resolving undocumented platform‑specific issues.

FreeBSD is a mature Unix operating system known for its stability, security, and well‑maintained ports ecosystem. It is frequently used in research computing environments and infrastructure systems. At the same time, the increasing adoption of ARM64 hardware—including Apple Silicon systems and ARM‑based servers—makes it increasingly important for scientific software to remain portable across architectures.

Currently, there is limited documentation describing how HEASoft can be compiled successfully on FreeBSD ARM64. The goal of this project is to provide a reproducible patch‑based framework enabling such builds while preserving compatibility with the upstream HEASoft source distribution.

# Software Description

## Architecture

The repository provides a lightweight porting framework that enables the original HEASoft source distribution to be compiled on FreeBSD ARM64 systems. The framework consists of three primary components:

1. **Patch series** addressing platform‑specific compilation and configuration issues.
2. **Environment configuration script** defining required compiler and library paths.
3. **Documentation and validation tests** that demonstrate successful compilation and execution.

The design intentionally avoids redistributing the HEASoft source code. Instead, users download the official HEASoft distribution from HEASARC and apply the patch framework locally.

This approach preserves compatibility with upstream releases while providing a transparent and reproducible method for building the software on FreeBSD ARM64 systems.

## Patch Framework

Several categories of issues were encountered during compilation:

- compiler compatibility adjustments
- platform‑specific header differences
- shell portability issues in build scripts
- installation rules for generated interface files
- Python wrapper packaging issues

Each issue is addressed through a numbered patch applied sequentially to the HEASoft source tree. Organizing the modifications as a patch series improves traceability and simplifies maintenance as upstream versions evolve.

The repository structure includes:

```
patches/
scripts/
heasoft_env.sh
INSTALL.md
VALIDATION.md
examples/
```

The patch application process is automated through a helper script that applies all required modifications to the extracted HEASoft source directory.

## Environment Configuration

Building HEASoft requires coordinating multiple toolchains including C, C++, and Fortran compilers, along with Tcl/Tk and Python environments.

The environment configuration script defines the required paths and environment variables used during compilation. This ensures consistent build behavior across FreeBSD installations.

An additional configuration step ensures that the **XSPEC Tcl readline interface** loads correctly. Without this adjustment, XSPEC may fall back to a minimal interactive prompt.

Example configuration:

```
export TCLLIBPATH="/usr/local/lib/tclreadline2.4.0 ${TCLLIBPATH:-}"
unset TCLRL_LIBDIR
```

# Validation

The compiled HEASoft environment was validated through functional testing of several key components.

## FTOOLS Test

Basic FITS file operations were performed using standard HEASoft utilities.

Example command:

```
ftlist <FITS_FILE>
```

Expected output (example placeholder):

```
$ ftlist "$HEADAS/refdata/pulsar_ephem_lib.fits"

Print options: H C K I T [H]

        Name               Type       Dimensions
        ----               ----       ----------
HDU 1   Primary Array      Image      Int2(1)
HDU 2   PSR_BIN            BinTable    10 cols x 25 rows
HDU 3   PSR_TIME           BinTable    16 cols x 1183 rows
HDU 4   LEAP_SECS          BinTable     2 cols x 22 rows
HDU 5   TIMELINE           BinTable     5 cols x 2840 rows
HDU 6   EPHEM_GRO          BinTable    16 cols x 4750 rows
```

These tests confirm correct integration of the CFITSIO library and core HEASoft utilities.

## XSPEC Test

The XSPEC spectral analysis environment was launched successfully.

Example session:

```
xspec
XSPEC12>
```

Example model initialization:

```
model powerlaw
```

Output placeholder:

```
$ xspec

        XSPEC version: 12.15.1
    Build Date/Time: Fri Mar  6 23:22:39 2026

XSPEC12> model powerlaw

Input parameter value, delta, min, bot, top, and max values for ...
              1       0.01(      0.01)         -3         -2          9         10
1:powerlaw:PhoIndex>0.1
              1       0.01(      0.01)          0          0      1e+20      1e+24
2:powerlaw:norm>1

========================================================================
Model powerlaw<1> Source No.: 1   Active/Off
Model Model Component  Parameter  Unit     Value
 par  comp
   1    1   powerlaw   PhoIndex            0.100000     +/-  0.0
   2    1   powerlaw   norm                1.00000      +/-  0.0
________________________________________________________________________
```

Successful execution confirms that XSPEC libraries and Tcl/Tk integration function correctly on FreeBSD ARM64.

## Python Interface Test

The Python interface `heasoftpy` was validated by importing the module in a Python environment.

Example command:

```
python3 -c "import heasoftpy as hsp; print(f'heasoftpy version = {hsp.__version__}')"
```

Output placeholder:

```
$ python3 -c "import heasoftpy as hsp; print(f'heasoftpy version = {hsp.__version__}')"
heasoftpy version = 1.5
```

This confirms that Python wrapper bindings to HEASoft tools are functional.

# Reproducibility

The repository provides detailed instructions for reproducing the build environment, including installation of FreeBSD within a UTM virtual machine, dependency installation, patch application, and compilation.

The reference test environment used in this work was:

- macOS host system
- UTM virtualization environment
- FreeBSD 15.0‑RELEASE ARM64
- HEASoft 6.36 source distribution

Full step‑by‑step instructions are provided in `INSTALL.md`, while validation procedures are documented in `VALIDATION.md`.

# Availability

## Source Code

Repository:

https://github.com/mranuraggarg/heasoft-freebsd-arm64-kit

The repository contains the patch framework and documentation required to compile HEASoft on FreeBSD ARM64 systems.

## License

The porting framework (patches, scripts, and documentation) is released under the **BSD‑3‑Clause license**.

The HEASoft source code itself is distributed separately by NASA HEASARC under its own licensing terms and must be downloaded from the official HEASARC website.

# Acknowledgements

The author acknowledges the HEASARC development team for maintaining the HEASoft software suite and providing open access to astrophysical data analysis tools.

# References

Arnaud, K. A. (1996). XSPEC: The First Ten Years. In *Astronomical Data Analysis Software and Systems V*. ASP Conference Series.