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

for p in "$patch_dir"/*.patch; do
  echo "Applying $(basename "$p")"
  (cd "$src_dir" && patch -p1 < "$p")
done

echo "Done."
