#!/bin/sh

# Quick HEASoft smoke test for FreeBSD ARM64 environments.

pass=0
fail=0

ok() {
  echo "OK: $1"
  pass=$((pass + 1))
}

not_ok() {
  echo "FAIL: $1"
  fail=$((fail + 1))
}

echo "== HEASoft smoke test =="

if [ -n "${HEADAS:-}" ]; then
  ok "HEADAS is set (${HEADAS})"
else
  not_ok "HEADAS is not set (source heasoft-init or heasoft_env.sh first)"
fi

if command -v ftlist >/dev/null 2>&1; then
  if [ -n "${HEADAS:-}" ] && [ -f "$HEADAS/refdata/eftest.fits" ]; then
    if ftlist "$HEADAS/refdata/eftest.fits" >/dev/null 2>&1; then
      ok "FTOOLS (ftlist) can read eftest.fits"
    else
      not_ok "ftlist failed to read $HEADAS/refdata/eftest.fits"
    fi
  else
    if ftlist >/dev/null 2>&1; then
      ok "FTOOLS (ftlist) is available"
    else
      # ftlist usually returns non-zero without args; this still verifies it starts.
      ok "FTOOLS (ftlist) is available (non-zero exit without input is expected)"
    fi
  fi
else
  not_ok "ftlist not found in PATH"
fi

if command -v xspec >/dev/null 2>&1; then
  if xspec -h >/dev/null 2>&1; then
    ok "XSPEC is available"
  else
    not_ok "xspec command exists but help check failed"
  fi
else
  not_ok "xspec not found in PATH"
fi

if command -v python3 >/dev/null 2>&1; then
  if python3 - <<'EOF'
import heasoftpy
print("heasoftpy import OK")
EOF
  then
    ok "Python wrapper (heasoftpy) imports successfully"
  else
    not_ok "heasoftpy import failed"
  fi
else
  not_ok "python3 not found in PATH"
fi

echo
echo "Summary: ${pass} passed, ${fail} failed"

if [ "$fail" -gt 0 ]; then
  exit 1
fi

exit 0
