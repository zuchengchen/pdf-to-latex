#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s SOURCE_PDF [TARGET_DIR] [TASK_PROFILE]\n' "$0" >&2
  printf 'Creates a resumable LaTeX conversion scaffold from bundled templates.\n' >&2
  printf 'TASK_PROFILE may be light, standard, book, math-heavy, or book-math.\n' >&2
}

if [[ $# -lt 1 || $# -gt 3 ]]; then
  usage
  exit 2
fi

source_pdf=$1
target_dir=${2:-latex}
task_profile=${3:-standard}

case "$task_profile" in
  light|standard|book|math-heavy|book-math) ;;
  *)
    printf 'Unsupported task profile: %s\n' "$task_profile" >&2
    usage
    exit 2
    ;;
esac

if [[ ! -f "$source_pdf" ]]; then
  printf 'Source PDF not found: %s\n' "$source_pdf" >&2
  exit 1
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
  printf 'Source file does not look like a PDF: %s\n' "$source_pdf" >&2
  exit 1
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
skill_dir=$(cd -- "$script_dir/.." && pwd)
template_dir="$skill_dir/assets/templates"

if [[ ! -d "$template_dir" ]]; then
  printf 'Template directory not found: %s\n' "$template_dir" >&2
  exit 1
fi

directory_has_entries() {
  local dir=$1
  local entries

  shopt -s nullglob dotglob
  entries=("$dir"/*)
  shopt -u nullglob dotglob
  [[ ${#entries[@]} -gt 0 ]]
}

directory_has_project_markers() {
  local dir=$1
  local marker

  for marker in conversion-state.md conversion-notes.md main.tex logs evidence/source-pages; do
    if [[ -e "$dir/$marker" ]]; then
      return 0
    fi
  done
  return 1
}

if [[ -e "$target_dir" && ! -d "$target_dir" ]]; then
  printf 'Target path exists but is not a directory: %s\n' "$target_dir" >&2
  exit 1
fi

if [[ -d "$target_dir" ]] && directory_has_entries "$target_dir" && ! directory_has_project_markers "$target_dir"; then
  printf 'Target directory is non-empty and has no recognizable conversion project markers: %s\n' "$target_dir" >&2
  printf 'Choose an empty directory, a resumable conversion project, or move unrelated files first.\n' >&2
  exit 1
fi

mkdir -p \
  "$target_dir/chapters" \
  "$target_dir/figures" \
  "$target_dir/tables" \
  "$target_dir/transcripts" \
  "$target_dir/evidence/source-pages" \
  "$target_dir/evidence/rebuilt-pages" \
  "$target_dir/evidence/crops" \
  "$target_dir/evidence/text-layer" \
  "$target_dir/logs"

if [[ "$task_profile" == book || "$task_profile" == book-math ]]; then
  mkdir -p "$target_dir/frontmatter" "$target_dir/backmatter"
fi

escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

source_pdf_value=$(escape_sed_replacement "$source_pdf")
target_dir_value=$(escape_sed_replacement "$target_dir")
task_profile_value=$(escape_sed_replacement "$task_profile")
date_value=$(date -u +%Y-%m-%dT%H:%M:%SZ)

copy_template() {
  local template_name=$1
  local destination=$2

  if [[ -e "$destination" ]]; then
    printf 'Keeping existing file: %s\n' "$destination"
    return
  fi

  sed \
    -e "s|{{SOURCE_PDF}}|$source_pdf_value|g" \
    -e "s|{{TARGET_DIR}}|$target_dir_value|g" \
    -e "s|{{TASK_PROFILE}}|$task_profile_value|g" \
    -e "s|{{DATE_UTC}}|$date_value|g" \
    "$template_dir/$template_name" >"$destination"
  printf 'Created %s\n' "$destination"
}

copy_template main.tex "$target_dir/main.tex"
copy_template conversion-state.md "$target_dir/conversion-state.md"
copy_template conversion-notes.md "$target_dir/conversion-notes.md"

if [[ "$task_profile" != light ]]; then
  copy_template page-manifest.md "$target_dir/page-manifest.md"
  copy_template object-inventory.md "$target_dir/object-inventory.md"
  copy_template style-profile.md "$target_dir/style-profile.md"
  copy_template document-ir.md "$target_dir/document-ir.md"
fi

if [[ "$task_profile" == math-heavy || "$task_profile" == book-math ]]; then
  copy_template math-inventory.md "$target_dir/math-inventory.md"
  copy_template glyph-map.md "$target_dir/glyph-map.md"
fi

printf 'Initialized LaTeX conversion scaffold in %s\n' "$target_dir"
