#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s [PROJECT_DIR] [PDF_FILE] [DPI] [--force] [--pages LIST | --from N --to M]\n' "$0" >&2
  printf 'Renders compiled PDF pages under PROJECT_DIR/evidence/rebuilt-pages.\n' >&2
  printf 'PDF_FILE defaults to main.pdf inside PROJECT_DIR.\n' >&2
}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

positional=()
render_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      render_args+=("$1")
      shift
      ;;
    --pages|--from|--to)
      [[ $# -ge 2 ]] || die "Missing value for $1."
      render_args+=("$1" "$2")
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

if [[ ${#positional[@]} -gt 3 ]]; then
  usage
  exit 2
fi

project_dir=${positional[0]:-.}
pdf_file=${positional[1]:-main.pdf}
dpi=${positional[2]:-140}

if [[ ! -d "$project_dir" ]]; then
  die "Project directory not found: $project_dir"
fi

case "$pdf_file" in
  /*) pdf_path=$pdf_file ;;
  *) pdf_path="$project_dir/$pdf_file" ;;
esac

if [[ ! -f "$pdf_path" && "$pdf_file" == main.pdf ]]; then
  shopt -s nullglob
  candidates=("$project_dir"/*.pdf)
  shopt -u nullglob
  if [[ ${#candidates[@]} -eq 1 ]]; then
    pdf_path=${candidates[0]}
  fi
fi

if [[ ! -f "$pdf_path" ]]; then
  die "Compiled PDF not found: $pdf_path"
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
"$script_dir/render_pdf_pages.sh" "$pdf_path" "$project_dir" "$dpi" --kind rebuilt "${render_args[@]}"
