#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s SOURCE_PDF [TARGET_DIR] [DPI] [--force] [--pages LIST | --from N --to M] [--kind source|rebuilt]\n' "$0" >&2
  printf 'Renders durable page evidence under TARGET_DIR/evidence/source-pages by default.\n' >&2
  printf 'LIST accepts comma-separated pages and ranges such as 1,3,5-8.\n' >&2
  printf 'Refuses to overwrite existing evidence for the selected pages unless --force is provided.\n' >&2
}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

positive_int() {
  local value=$1
  [[ "$value" =~ ^[0-9]+$ ]] || return 1
  ((10#$value > 0))
}

force=false
pages_arg=
from_page=
to_page=
evidence_kind=source
positional=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      force=true
      shift
      ;;
    --pages)
      [[ $# -ge 2 ]] || die 'Missing value for --pages.'
      pages_arg=$2
      shift 2
      ;;
    --from)
      [[ $# -ge 2 ]] || die 'Missing value for --from.'
      from_page=$2
      shift 2
      ;;
    --to)
      [[ $# -ge 2 ]] || die 'Missing value for --to.'
      to_page=$2
      shift 2
      ;;
    --kind|--evidence-kind)
      [[ $# -ge 2 ]] || die 'Missing value for --kind.'
      evidence_kind=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      usage
      die "Unknown option: $1"
      ;;
    *)
      positional+=("$1")
      shift
      ;;
  esac
done

if [[ ${#positional[@]} -lt 1 || ${#positional[@]} -gt 3 ]]; then
  usage
  exit 2
fi

source_pdf=${positional[0]}
target_dir=${positional[1]:-latex}
dpi=${positional[2]:-180}

if [[ ! -f "$source_pdf" ]]; then
  die "Source PDF not found: $source_pdf"
fi

if ! positive_int "$dpi"; then
  die "DPI must be a positive integer: $dpi"
fi

case "$evidence_kind" in
  source|rebuilt) ;;
  *)
    die "Unsupported evidence kind: $evidence_kind"
    ;;
esac

looks_like_pdf() {
  local path=$1

  if ! LC_ALL=C grep -aq '%PDF-' < <(head -c 1024 "$path"); then
    return 1
  fi

  if command -v pdfinfo >/dev/null 2>&1; then
    pdfinfo "$path" >/dev/null 2>&1
    return
  fi

  return 0
}

if ! looks_like_pdf "$source_pdf"; then
  die "Source file does not look like a PDF: $source_pdf"
fi

page_count=
if command -v pdfinfo >/dev/null 2>&1; then
  page_count=$(pdfinfo "$source_pdf" 2>/dev/null | awk '/^Pages:/ {print $2; exit}') || true
fi

candidate_pages=()
selected_pages=()
render_ranges=()

add_page() {
  local page=$1

  if ! positive_int "$page"; then
    die "Page must be a positive integer: $page"
  fi
  page=$((10#$page))
  candidate_pages+=("$page")
}

add_range() {
  local start=$1
  local end=$2
  local page

  if ! positive_int "$start" || ! positive_int "$end"; then
    die "Page range must use positive integers: $start-$end"
  fi
  start=$((10#$start))
  end=$((10#$end))
  if [[ "$start" -gt "$end" ]]; then
    die "Page range start must be before end: $start-$end"
  fi
  render_ranges+=("$start:$end")
  for ((page = start; page <= end; page++)); do
    add_page "$page"
  done
}

if [[ -n "$pages_arg" && ( -n "$from_page" || -n "$to_page" ) ]]; then
  die 'Use either --pages or --from/--to, not both.'
fi

if [[ -n "$pages_arg" ]]; then
  IFS=',' read -r -a page_tokens <<<"$pages_arg"
  for token in "${page_tokens[@]}"; do
    token=${token//[[:space:]]/}
    if [[ -z "$token" ]]; then
      die "Empty page token in --pages: $pages_arg"
    elif [[ "$token" =~ ^([0-9]+)-([0-9]+)$ ]]; then
      add_range "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    elif [[ "$token" =~ ^[0-9]+$ ]]; then
      add_range "$token" "$token"
    else
      die "Invalid page token in --pages: $token"
    fi
  done
elif [[ -n "$from_page" || -n "$to_page" ]]; then
  [[ -n "$from_page" && -n "$to_page" ]] || die 'Use --from and --to together.'
  add_range "$from_page" "$to_page"
fi

if [[ ${#candidate_pages[@]} -gt 0 ]]; then
  mapfile -t selected_pages < <(printf '%s\n' "${candidate_pages[@]}" | sort -n -u)
  if [[ -n "$page_count" ]]; then
    for page in "${selected_pages[@]}"; do
      if [[ "$page" -gt "$page_count" ]]; then
        die "Selected page $page exceeds PDF page count $page_count."
      fi
    done
  fi
fi

out_dir="$target_dir/evidence/${evidence_kind}-pages"
log_dir="$target_dir/logs"
mkdir -p "$out_dir" "$log_dir"

page_base_variants() {
  local page=$1
  local padded

  printf -v padded 'page-%03d' "$page"
  printf '%s\n' "$padded" "page-$page"
}

remove_selected_page_evidence() {
  local page
  local base

  for page in "${selected_pages[@]}"; do
    while IFS= read -r base; do
      rm -f -- "$out_dir/$base.png" "$out_dir/$base.pdf"
    done < <(page_base_variants "$page")
  done
}

remove_all_page_evidence() {
  local existing

  shopt -s nullglob
  for existing in "$out_dir"/page-*.png "$out_dir"/page-*.pdf; do
    rm -f -- "$existing"
  done
  shopt -u nullglob
}

existing_all_page_evidence_count() {
  local existing_pages

  shopt -s nullglob
  existing_pages=("$out_dir"/page-*.png "$out_dir"/page-*.pdf)
  shopt -u nullglob
  printf '%s' "${#existing_pages[@]}"
}

existing_selected_page_evidence_count() {
  local page
  local base
  local count=0

  for page in "${selected_pages[@]}"; do
    while IFS= read -r base; do
      [[ -e "$out_dir/$base.png" ]] && ((count += 1))
      [[ -e "$out_dir/$base.pdf" ]] && ((count += 1))
    done < <(page_base_variants "$page")
  done

  printf '%s' "$count"
}

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
        if [[ -e "$out_dir/$padded" && "$force" != true ]]; then
          printf 'Refusing to overwrite existing rendered page: %s\n' "$out_dir/$padded" >&2
          printf 'Re-run with --force to replace existing page evidence.\n' >&2
          exit 1
        fi
        mv -f -- "$path" "$out_dir/$padded"
      fi
    fi
  done
  shopt -u nullglob
}

if [[ ${#selected_pages[@]} -gt 0 ]]; then
  if [[ $(existing_selected_page_evidence_count) -gt 0 ]]; then
    if [[ "$force" == true ]]; then
      remove_selected_page_evidence
    else
      printf 'Page evidence already exists for at least one selected page in %s\n' "$out_dir" >&2
      printf 'Re-run with --force to replace selected page evidence.\n' >&2
      exit 1
    fi
  fi
else
  if [[ $(existing_all_page_evidence_count) -gt 0 ]]; then
    if [[ "$force" == true ]]; then
      remove_all_page_evidence
    else
      printf 'Page evidence already exists in %s\n' "$out_dir" >&2
      printf 'Re-run with --force to replace existing page evidence.\n' >&2
      exit 1
    fi
  fi
fi

pdfseparate_log="$log_dir/pdfseparate-${evidence_kind}.log"
renderer_log="$log_dir/render-${evidence_kind}-pages.log"
: >"$pdfseparate_log"
: >"$renderer_log"

render_pdf_range() {
  local start=$1
  local end=$2
  local page_spec

  if command -v pdfseparate >/dev/null 2>&1; then
    if ! pdfseparate -f "$start" -l "$end" "$source_pdf" "$out_dir/page-%03d.pdf" >>"$pdfseparate_log" 2>&1; then
      printf 'Warning: pdfseparate failed for pages %s-%s; see %s\n' "$start" "$end" "$pdfseparate_log" >&2
    fi
  fi

  if command -v pdftoppm >/dev/null 2>&1; then
    pdftoppm -png -r "$dpi" -f "$start" -l "$end" "$source_pdf" "$out_dir/page" >>"$renderer_log" 2>&1
  elif command -v mutool >/dev/null 2>&1; then
    page_spec=$start
    if [[ "$start" != "$end" ]]; then
      page_spec="$start-$end"
    fi
    mutool draw -o "$out_dir/page-%03d.png" -r "$dpi" "$source_pdf" "$page_spec" >>"$renderer_log" 2>&1
  else
    die 'Missing renderer: install or provide pdftoppm or mutool.'
  fi
}

if [[ ${#render_ranges[@]} -gt 0 ]]; then
  for range in "${render_ranges[@]}"; do
    render_pdf_range "${range%%:*}" "${range##*:}"
  done
else
  if command -v pdfseparate >/dev/null 2>&1; then
    if ! pdfseparate "$source_pdf" "$out_dir/page-%03d.pdf" >>"$pdfseparate_log" 2>&1; then
      printf 'Warning: pdfseparate failed; see %s\n' "$pdfseparate_log" >&2
    fi
  fi

  if command -v pdftoppm >/dev/null 2>&1; then
    pdftoppm -png -r "$dpi" "$source_pdf" "$out_dir/page" >>"$renderer_log" 2>&1
  elif command -v mutool >/dev/null 2>&1; then
    mutool draw -o "$out_dir/page-%03d.png" -r "$dpi" "$source_pdf" >>"$renderer_log" 2>&1
  else
    die 'Missing renderer: install or provide pdftoppm or mutool.'
  fi
fi

normalize_png_names

if [[ ${#selected_pages[@]} -gt 0 ]]; then
  missing_pages=()
  for page in "${selected_pages[@]}"; do
    printf -v padded 'page-%03d.png' "$page"
    if [[ ! -f "$out_dir/$padded" ]]; then
      missing_pages+=("$page")
    fi
  done
  if [[ ${#missing_pages[@]} -gt 0 ]]; then
    printf 'Renderer finished but selected page PNG files were missing in %s: %s\n' "$out_dir" "${missing_pages[*]}" >&2
    exit 1
  fi
else
  shopt -s nullglob
  rendered_pages=("$out_dir"/page-*.png)
  shopt -u nullglob
  if [[ ${#rendered_pages[@]} -eq 0 ]]; then
    printf 'Renderer finished but no page PNG files were found in %s\n' "$out_dir" >&2
    exit 1
  fi
fi

printf 'Rendered %s page evidence in %s\n' "$evidence_kind" "$out_dir"
