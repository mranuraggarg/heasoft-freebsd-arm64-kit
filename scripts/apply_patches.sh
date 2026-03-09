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
  echo "Applying $(basename "$p")"
  # -N: ignore already-applied hunks, -t: batch mode (no interactive prompts)
  if ! (cd "$src_dir" && patch -N -t -p1 < "$p"); then
    echo "Error: failed to apply $(basename "$p")" >&2
    exit 1
  fi
  if find "$src_dir" -name '*.rej' -print -quit | grep -q .; then
    echo "Error: reject file(s) found after $(basename "$p")" >&2
    find "$src_dir" -name '*.rej' -print >&2
    exit 1
  fi
done

echo "Done."
