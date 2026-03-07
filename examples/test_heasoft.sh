#!/bin/sh

# Quick HEASoft smoke test for FreeBSD ARM64 environments.

pass=0
fail=0
warn=0

ok() {
  echo "OK: $1"
  pass=$((pass + 1))
}

not_ok() {
  echo "FAIL: $1"
  fail=$((fail + 1))
}

warn_msg() {
  echo "WARN: $1"
  warn=$((warn + 1))
}

echo "== HEASoft smoke test =="

if [ -n "${HEADAS:-}" ]; then
  ok "HEADAS is set (${HEADAS})"
  if [ -d "$HEADAS" ]; then
    ok "HEADAS directory exists"
  else
    not_ok "HEADAS directory does not exist: $HEADAS"
  fi
  if [ -d "$HEADAS/refdata" ]; then
    ok "HEADAS refdata directory exists"
  else
    not_ok "HEADAS refdata directory missing: $HEADAS/refdata"
  fi
else
  not_ok "HEADAS is not set (source heasoft-init or heasoft_env.sh first)"
fi

if [ -n "${HEADAS:-}" ]; then
  case ":$PATH:" in
    *":$HEADAS/bin:"*) ok "PATH contains \$HEADAS/bin" ;;
    *) not_ok "PATH does not include \$HEADAS/bin" ;;
  esac
fi

if [ -n "${PFILES:-}" ]; then
  pfiles_local="${PFILES%%;*}"
  if [ -n "$pfiles_local" ] && [ -w "$pfiles_local" ]; then
    ok "PFILES local path is writable (${pfiles_local})"
  else
    warn_msg "PFILES set but local path may be unwritable (${pfiles_local})"
  fi
else
  warn_msg "PFILES is not set; some FTOOLS may prompt or fail in scripted runs"
fi

if [ -n "${TCLLIBPATH:-}" ]; then
  case " ${TCLLIBPATH} " in
    *tclreadline*) ok "TCLLIBPATH includes tclreadline path" ;;
    *) warn_msg "TCLLIBPATH is set but does not appear to include tclreadline" ;;
  esac
else
  warn_msg "TCLLIBPATH is not set; XSPEC may fall back to '%' prompt"
fi

if command -v ftlist >/dev/null 2>&1; then
  if [ -n "${HEADAS:-}" ] && [ -f "$HEADAS/refdata/pulsar_ephem_lib.fits" ]; then
    if printf 'H\n' | ftlist "$HEADAS/refdata/pulsar_ephem_lib.fits" >/dev/null 2>&1; then
      ok "FTOOLS (ftlist) can read pulsar_ephem_lib.fits"
    else
      not_ok "ftlist failed to read $HEADAS/refdata/pulsar_ephem_lib.fits"
    fi
  else
    ok "FTOOLS (ftlist) is available (read test skipped: missing \$HEADAS/refdata/pulsar_ephem_lib.fits)"
  fi
else
  not_ok "ftlist not found in PATH"
fi

if command -v xspec >/dev/null 2>&1; then
  if printf 'quit\n' | xspec >/dev/null 2>&1; then
    ok "XSPEC is available"
  else
    not_ok "xspec command exists but non-interactive startup/quit check failed"
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
echo "Summary: ${pass} passed, ${fail} failed, ${warn} warnings"

if [ "$fail" -gt 0 ]; then
  exit 1
fi

exit 0
