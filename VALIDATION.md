# Validation Test

After compiling HEASoft on FreeBSD ARM64, run the following checks to confirm the environment is functional.

## FTOOLS test

```sh
ftlist "$HEADAS/refdata/eftest.fits"
```

Expected output includes FITS header information.

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
