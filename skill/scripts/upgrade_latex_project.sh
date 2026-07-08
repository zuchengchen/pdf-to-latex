#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s TARGET_DIR NEW_PROFILE [SOURCE_PDF] [DELIVERY_LEVEL]\n' "$0" >&2
  printf 'Adds missing profile-specific scaffold files without overwriting existing project files.\n' >&2
  printf 'NEW_PROFILE may be light, standard, book, math-heavy, or book-math.\n' >&2
}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

if [[ $# -lt 2 || $# -gt 4 ]]; then
  usage
  exit 2
fi

target_dir=$1
new_profile=$2
source_pdf=${3:-}
delivery_level=${4:-}

case "$new_profile" in
  light|standard|book|math-heavy|book-math) ;;
  *)
    printf 'Unsupported task profile: %s\n' "$new_profile" >&2
    usage
    exit 2
    ;;
esac

case "$delivery_level" in
  ""|"rough draft"|"clean semantic"|"publication polish") ;;
  rough|rough-draft)
    delivery_level="rough draft"
    ;;
  clean|clean-semantic)
    delivery_level="clean semantic"
    ;;
  publication|publication-polish|polish)
    delivery_level="publication polish"
    ;;
  *)
    printf 'Unsupported delivery level: %s\n' "$delivery_level" >&2
    usage
    exit 2
    ;;
esac

if [[ ! -d "$target_dir" ]]; then
  die "Target directory not found: $target_dir"
fi

has_project_marker=false
for marker in conversion-state.md conversion-notes.md main.tex; do
  if [[ -f "$target_dir/$marker" ]]; then
    has_project_marker=true
    break
  fi
done

if [[ "$has_project_marker" != true ]]; then
  die "Target directory has no recognizable conversion project markers: $target_dir"
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
skill_dir=$(cd -- "$script_dir/.." && pwd)
template_dir="$skill_dir/assets/templates"

if [[ ! -d "$template_dir" ]]; then
  die "Template directory not found: $template_dir"
fi

read_field() {
  local field=$1
  local file=$2

  if [[ -f "$file" ]]; then
    sed -n "s/^$field:[[:space:]]*//p" "$file" | head -n 1
  fi
}

if [[ -z "$source_pdf" ]]; then
  source_pdf=$(read_field 'Source PDF' "$target_dir/conversion-state.md")
fi
if [[ -z "$source_pdf" ]]; then
  source_pdf=$(read_field 'Source PDF' "$target_dir/conversion-notes.md")
fi
if [[ -z "$source_pdf" ]]; then
  source_pdf="unknown"
fi

if [[ -z "$delivery_level" ]]; then
  delivery_level=$(read_field 'Delivery level' "$target_dir/conversion-state.md")
fi
if [[ -z "$delivery_level" ]]; then
  delivery_level=$(read_field 'Delivery level' "$target_dir/conversion-notes.md")
fi
if [[ -z "$delivery_level" ]]; then
  delivery_level="clean semantic"
fi

case "$delivery_level" in
  "rough draft"|rough|rough-draft)
    delivery_level="rough draft"
    ;;
  "clean semantic"|clean|clean-semantic)
    delivery_level="clean semantic"
    ;;
  "publication polish"|publication|publication-polish|polish)
    delivery_level="publication polish"
    ;;
  *)
    printf 'Unsupported delivery level: %s\n' "$delivery_level" >&2
    usage
    exit 2
    ;;
esac

escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

source_pdf_value=$(escape_sed_replacement "$source_pdf")
target_dir_value=$(escape_sed_replacement "$target_dir")
new_profile_value=$(escape_sed_replacement "$new_profile")
delivery_level_value=$(escape_sed_replacement "$delivery_level")
date_value=$(date -u +%Y-%m-%dT%H:%M:%SZ)

source_page_size() {
  local value

  if [[ -f "$source_pdf" ]] && command -v pdfinfo >/dev/null 2>&1; then
    value=$(pdfinfo "$source_pdf" 2>/dev/null | sed -n 's/^Page size:[[:space:]]*//p' | head -n 1 || true)
    if [[ -n "$value" ]]; then
      printf '%s' "$value"
      return
    fi
  fi

  printf 'pending; inspect source PDF page size with pdfinfo'
}

source_page_size_value=$(escape_sed_replacement "$(source_page_size)")

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
    -e "s|{{TASK_PROFILE}}|$new_profile_value|g" \
    -e "s|{{DELIVERY_LEVEL}}|$delivery_level_value|g" \
    -e "s|{{DATE_UTC}}|$date_value|g" \
    -e "s|{{SOURCE_PAGE_SIZE}}|$source_page_size_value|g" \
    "$template_dir/$template_name" >"$destination"
  printf 'Created %s\n' "$destination"
}

mkdir -p "$target_dir/logs"

if [[ "$new_profile" != light ]]; then
  mkdir -p \
    "$target_dir/chapters" \
    "$target_dir/figures" \
    "$target_dir/tables" \
    "$target_dir/transcripts" \
    "$target_dir/evidence/source-pages" \
    "$target_dir/evidence/rebuilt-pages" \
    "$target_dir/evidence/crops" \
    "$target_dir/evidence/text-layer"
fi

copy_template conversion-state.md "$target_dir/conversion-state.md"
copy_template conversion-notes.md "$target_dir/conversion-notes.md"

if [[ "$new_profile" != light ]]; then
  copy_template page-manifest.md "$target_dir/page-manifest.md"
  copy_template object-inventory.md "$target_dir/object-inventory.md"
  copy_template style-profile.md "$target_dir/style-profile.md"
  copy_template document-ir.md "$target_dir/document-ir.md"
fi

if [[ "$new_profile" == book || "$new_profile" == book-math ]]; then
  mkdir -p "$target_dir/frontmatter" "$target_dir/backmatter"
fi

if [[ "$new_profile" == math-heavy || "$new_profile" == book-math ]]; then
  copy_template math-inventory.md "$target_dir/math-inventory.md"
  copy_template glyph-map.md "$target_dir/glyph-map.md"
fi

printf 'Profile scaffold additions are present for %s in %s\n' "$new_profile" "$target_dir"
printf 'Update conversion-state.md and conversion-notes.md with the profile upgrade reason and next action.\n'
