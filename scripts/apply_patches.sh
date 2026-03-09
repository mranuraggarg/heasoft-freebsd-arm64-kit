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
  else
    echo "Error: patch cannot be applied cleanly: ${pbase}" >&2
    exit 1
  fi
done

echo "Done."
