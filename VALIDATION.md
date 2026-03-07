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
