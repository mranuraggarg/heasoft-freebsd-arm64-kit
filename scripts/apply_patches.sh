#!/usr/bin/env sh
set -eu

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 /path/to/heasoft-6.36" >&2
  exit 1
fi

src_dir="$1"
patch_dir="$(CDPATH= cd -- "$(dirname -- "$0")/../patches" && pwd)"

if [ ! -d "$src_dir" ]; then
  echo "Error: source dir not found: $src_dir" >&2
  exit 1
fi

# Refuse to proceed if stale reject files already exist from a prior run.
if find "$src_dir" -name '*.rej' -print -quit | grep -q .; then
  echo "Error: pre-existing reject file(s) found in source tree." >&2
  echo "Please clean them (or re-extract a fresh HEASoft tree) and rerun." >&2
  find "$src_dir" -name '*.rej' -print >&2
  exit 1
fi

apply_0008_fallback() {
  fp="$src_dir/heacore/gsl/ieee-utils/fp.c"
  if [ ! -f "$fp" ]; then
    echo "Error: expected file not found for 0008 fallback: $fp" >&2
    return 1
  fi

  # If arm64 path is already present, treat as already applied.
  if grep -Eq '__aarch64__|__arm64__' "$fp"; then
    echo "Skipping 0008-gsl-freebsd-prioritize-arm64-ieee-backend.patch (already applied)"
    return 0
  fi

  tmp="${fp}.tmp.$$"
  if ! perl -0777 -pe '
    s{(#elif HAVE_FREEBSD_IEEE_INTERFACE\s*\n)\s*# if defined\(__i386__\)\s*\|\|\s*defined\(__x86_64__\)(?:\s*\|\|\s*defined\(__amd64__\))?\s*\n\s*#  include "fp-freebsd\.c"}
     {$1# if defined(__aarch64__) || defined(__arm64__)\n#  include "fp-gnuc99.c"\n# elif defined(__i386__) || defined(__x86_64__) || defined(__amd64__)\n#  include "fp-freebsd.c"}sex
  ' "$fp" > "$tmp"; then
    rm -f "$tmp"
    echo "Error: perl fallback transform failed for $fp" >&2
    return 1
  fi

  if cmp -s "$fp" "$tmp"; then
    rm -f "$tmp"
    echo "Error: 0008 fallback made no changes; fp.c layout not recognized" >&2
    return 1
  fi

  mv "$tmp" "$fp"
  echo "Applied 0008 fallback directly to heacore/gsl/ieee-utils/fp.c"
  return 0
}

for p in "$patch_dir"/*.patch; do
  pbase="$(basename "$p")"
  echo "Applying ${pbase}"
  # Idempotent behavior:
  #   1) if forward dry-run succeeds -> apply patch
  #   2) else if reverse dry-run succeeds -> already applied, skip
  #   3) else -> real conflict/failure
  if (cd "$src_dir" && patch -p1 -t --dry-run < "$p" >/dev/null 2>&1); then
    if ! (cd "$src_dir" && patch -p1 -t < "$p"); then
      echo "Error: failed to apply ${pbase}" >&2
      exit 1
    fi
  elif (cd "$src_dir" && patch -R -p1 -t --dry-run < "$p" >/dev/null 2>&1); then
    echo "Skipping ${pbase} (already applied)"
  elif [ "$pbase" = "0008-gsl-freebsd-prioritize-arm64-ieee-backend.patch" ]; then
    if ! apply_0008_fallback; then
      echo "Error: patch cannot be applied cleanly: ${pbase}" >&2
      exit 1
    fi
  else
    echo "Error: patch cannot be applied cleanly: ${pbase}" >&2
    exit 1
  fi
done

echo "Done."
