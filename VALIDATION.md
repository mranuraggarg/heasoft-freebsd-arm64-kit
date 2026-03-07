# Validation Test

After compiling HEASoft on FreeBSD ARM64, run the following checks to confirm the environment is functional.

## FTOOLS test

```sh
ftlist "$HEADAS/refdata/pulsar_ephem_lib.fits"
```

Expected output includes FITS HDU and table metadata.

## XSPEC test

```sh
xspec
```

At the prompt:

```text
XSPEC12> model powerlaw
XSPEC12> fit
```

## Python interface test

```sh
python3 -c "import heasoftpy"
```

## Optional one-shot smoke test

Run:

```sh
./examples/test_heasoft.sh
```

This smoke test now checks:
- `HEADAS`, `PATH`, and `PFILES` sanity
- FTOOLS read test on `pulsar_ephem_lib.fits`
- non-interactive XSPEC startup/quit
- `heasoftpy` import via Python

Warnings are informational (for example missing `TCLLIBPATH` tuning), while failures indicate broken setup.
