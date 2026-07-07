#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s SOURCE_PDF [TARGET_DIR] [DPI]\n' "$0" >&2
  printf 'Renders durable page evidence under TARGET_DIR/evidence/source-pages.\n' >&2
}

if [[ $# -lt 1 || $# -gt 3 ]]; then
  usage
  exit 2
fi

source_pdf=$1
target_dir=${2:-latex}
dpi=${3:-180}

if [[ ! -f "$source_pdf" ]]; then
  printf 'Source PDF not found: %s\n' "$source_pdf" >&2
  exit 1
fi

case "$dpi" in
  ''|*[!0-9]*)
    printf 'DPI must be a positive integer: %s\n' "$dpi" >&2
    exit 2
    ;;
esac

out_dir="$target_dir/evidence/source-pages"
log_dir="$target_dir/logs"
mkdir -p "$out_dir" "$log_dir"

normalize_png_names() {
  local page_number
  local path
  local base
  local raw_number
  local padded

  shopt -s nullglob
  for path in "$out_dir"/page-*.png; do
    base=${path##*/}
    if [[ $base =~ ^page-([0-9]+)\.png$ ]]; then
      raw_number=${BASH_REMATCH[1]}
      page_number=$((10#$raw_number))
      printf -v padded 'page-%03d.png' "$page_number"
      if [[ $base != "$padded" ]]; then
        mv -f -- "$path" "$out_dir/$padded"
      fi
    fi
  done
  shopt -u nullglob
}

if command -v pdfseparate >/dev/null 2>&1; then
  if ! pdfseparate "$source_pdf" "$out_dir/page-%03d.pdf" >"$log_dir/pdfseparate.log" 2>&1; then
    printf 'Warning: pdfseparate failed; see %s\n' "$log_dir/pdfseparate.log" >&2
  fi
fi

if command -v pdftoppm >/dev/null 2>&1; then
  pdftoppm -png -r "$dpi" "$source_pdf" "$out_dir/page" >"$log_dir/pdftoppm.log" 2>&1
elif command -v mutool >/dev/null 2>&1; then
  mutool draw -o "$out_dir/page-%03d.png" -r "$dpi" "$source_pdf" >"$log_dir/mutool-draw.log" 2>&1
else
  printf 'Missing renderer: install or provide pdftoppm or mutool.\n' >&2
  exit 1
fi

normalize_png_names

shopt -s nullglob
rendered_pages=("$out_dir"/page-*.png)
shopt -u nullglob
if [[ ${#rendered_pages[@]} -eq 0 ]]; then
  printf 'Renderer finished but no page PNG files were found in %s\n' "$out_dir" >&2
  exit 1
fi

printf 'Rendered page evidence in %s\n' "$out_dir"
