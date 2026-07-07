#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s SOURCE_PDF [TARGET_DIR] [--force] [--pages LIST | --from N --to M]\n' "$0" >&2
  printf 'Extracts page-bounded digital text-layer evidence under TARGET_DIR/evidence/text-layer.\n' >&2
  printf 'LIST accepts comma-separated pages and ranges such as 1,3,5-8.\n' >&2
  printf 'This uses pdftotext only; it does not perform OCR.\n' >&2
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

if [[ ${#positional[@]} -lt 1 || ${#positional[@]} -gt 2 ]]; then
  usage
  exit 2
fi

source_pdf=${positional[0]}
target_dir=${positional[1]:-latex}

if [[ ! -f "$source_pdf" ]]; then
  die "Source PDF not found: $source_pdf"
fi

if ! command -v pdftotext >/dev/null 2>&1; then
  die 'Missing tool: pdftotext is required for digital text-layer extraction.'
fi

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
elif [[ -n "$page_count" ]]; then
  add_range 1 "$page_count"
else
  die 'Could not determine page count; specify --pages or --from/--to.'
fi

mapfile -t selected_pages < <(printf '%s\n' "${candidate_pages[@]}" | sort -n -u)

if [[ -n "$page_count" ]]; then
  for page in "${selected_pages[@]}"; do
    if [[ "$page" -gt "$page_count" ]]; then
      die "Selected page $page exceeds PDF page count $page_count."
    fi
  done
fi

out_dir="$target_dir/evidence/text-layer"
log_dir="$target_dir/logs"
mkdir -p "$out_dir" "$log_dir"
log_file="$log_dir/extract-text-pages.log"
: >"$log_file"

page_base_variants() {
  local page=$1
  local padded

  printf -v padded 'page-%03d' "$page"
  printf '%s\n' "$padded" "page-$page"
}

for page in "${selected_pages[@]}"; do
  while IFS= read -r base; do
    if [[ -e "$out_dir/$base.txt" ]]; then
      if [[ "$force" == true ]]; then
        rm -f -- "$out_dir/$base.txt"
      else
        printf 'Text-layer evidence already exists for page %s in %s\n' "$page" "$out_dir" >&2
        printf 'Re-run with --force to replace selected text evidence.\n' >&2
        exit 1
      fi
    fi
  done < <(page_base_variants "$page")
done

for page in "${selected_pages[@]}"; do
  printf -v output_path '%s/page-%03d.txt' "$out_dir" "$page"
  if ! pdftotext -f "$page" -l "$page" -layout "$source_pdf" "$output_path" >>"$log_file" 2>&1; then
    printf 'pdftotext failed for page %s; see %s\n' "$page" "$log_file" >&2
    exit 1
  fi
done

printf 'Extracted text-layer evidence in %s\n' "$out_dir"
