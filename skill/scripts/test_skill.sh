#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s [--metadata-only|--skip-metadata]\n' "$0" >&2
  printf 'Runs skill metadata, shell syntax, and helper smoke checks.\n' >&2
}

mode=all
if [[ $# -gt 1 ]]; then
  usage
  exit 2
elif [[ $# -eq 1 ]]; then
  case "$1" in
    --metadata-only) mode=metadata_only ;;
    --skip-metadata) mode=skip_metadata ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 2
      ;;
  esac
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
skill_dir=$(cd -- "$script_dir/.." && pwd)

if [[ "$mode" != skip_metadata ]]; then
  validator="${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py"
  if [[ -f "$validator" ]]; then
    python "$validator" "$skill_dir"
  else
    skill_file="$skill_dir/SKILL.md"
    if [[ ! -f "$skill_file" ]]; then
      printf 'Missing SKILL.md at %s\n' "$skill_file" >&2
      exit 1
    fi
    if [[ $(sed -n '1p' "$skill_file") != '---' ]]; then
      printf 'SKILL.md must start with YAML frontmatter.\n' >&2
      exit 1
    fi
    if ! sed -n '2,/^---$/p' "$skill_file" | grep -Eq '^name: pdf-to-latex$'; then
      printf 'SKILL.md frontmatter must include name: pdf-to-latex.\n' >&2
      exit 1
    fi
    if ! sed -n '2,/^---$/p' "$skill_file" | grep -Eq '^description: ".+"$'; then
      printf 'SKILL.md frontmatter must include a quoted description.\n' >&2
      exit 1
    fi
    printf 'Fallback metadata validation passed.\n'
  fi
fi

if [[ "$mode" == metadata_only ]]; then
  exit 0
fi

bash -n "$script_dir"/*.sh

tmp_dir=$(mktemp -d)
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

create_minimal_pdf() {
  local destination=$1

  printf '%s\n' \
    '%PDF-1.4' \
    '1 0 obj' \
    '<< /Type /Catalog /Pages 2 0 R >>' \
    'endobj' \
    '2 0 obj' \
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>' \
    'endobj' \
    '3 0 obj' \
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 72 72] /Resources << >> /Contents 4 0 R >>' \
    'endobj' \
    '4 0 obj' \
    '<< /Length 0 >>' \
    'stream' \
    '' \
    'endstream' \
    'endobj' \
    'xref' \
    '0 5' \
    '0000000000 65535 f ' \
    '0000000009 00000 n ' \
    '0000000058 00000 n ' \
    '0000000115 00000 n ' \
    '0000000217 00000 n ' \
    'trailer' \
    '<< /Size 5 /Root 1 0 R >>' \
    'startxref' \
    '266' \
    '%%EOF' >"$destination"
}

clean_project="$tmp_dir/clean"
dirty_project="$tmp_dir/dirty"
empty_project="$tmp_dir/empty"
nonstandard_project="$tmp_dir/nonstandard"
false_positive_project="$tmp_dir/false-positive"
mkdir -p \
  "$clean_project/chapters" \
  "$dirty_project/chapters" \
  "$empty_project" \
  "$nonstandard_project/sections" \
  "$false_positive_project/chapters"

printf '\\documentclass{article}\\begin{document}Clean\\end{document}\\n' >"$clean_project/main.tex"
printf 'This source contains no blocking extraction artifacts.\\n' >"$clean_project/chapters/content.tex"

printf '\\documentclass{article}\\begin{document}\\pdfglyph{bad}\\end{document}\\n' >"$dirty_project/main.tex"

printf '\\documentclass{article}\\begin{document}\\input{sections/content}\\end{document}\\n' >"$nonstandard_project/main.tex"
printf 'Formula artifact: \\pdfglyph{bad}.\\n' >"$nonstandard_project/sections/content.tex"

printf '\\documentclass{article}\\begin{document}\\input{chapters/content}\\end{document}\\n' >"$false_positive_project/main.tex"
printf 'This chapter explains that this is not a raw glyph placeholder.\\n' >"$false_positive_project/chapters/content.tex"

"$script_dir/check_latex_artifacts.sh" "$clean_project" >/dev/null

if "$script_dir/check_latex_artifacts.sh" "$dirty_project" >/dev/null 2>&1; then
  printf 'Expected artifact scan to fail for dirty project.\n' >&2
  exit 1
fi

if "$script_dir/check_latex_artifacts.sh" "$nonstandard_project" >/dev/null 2>&1; then
  printf 'Expected artifact scan to fail for nonstandard included source.\n' >&2
  exit 1
fi

"$script_dir/check_latex_artifacts.sh" "$false_positive_project" >/dev/null

if "$script_dir/check_latex_artifacts.sh" "$empty_project" >/dev/null 2>&1; then
  printf 'Expected artifact scan to fail when no source files exist.\n' >&2
  exit 1
fi

source_pdf="$tmp_dir/source.pdf"
scaffold_project="$tmp_dir/scaffold"
not_pdf="$tmp_dir/not-a-pdf.pdf"
create_minimal_pdf "$source_pdf"
printf 'placeholder pdf bytes for scaffold smoke test\n' >"$not_pdf"

if "$script_dir/init_latex_project.sh" "$not_pdf" "$tmp_dir/not-pdf-scaffold" standard >/dev/null 2>&1; then
  printf 'Expected scaffold initialization to reject a non-PDF source file.\n' >&2
  exit 1
fi

unrelated_project="$tmp_dir/unrelated"
mkdir -p "$unrelated_project"
printf 'user notes\n' >"$unrelated_project/notes.txt"
if "$script_dir/init_latex_project.sh" "$source_pdf" "$unrelated_project" standard >/dev/null 2>&1; then
  printf 'Expected scaffold initialization to reject a non-empty unrelated target directory.\n' >&2
  exit 1
fi

logs_only_project="$tmp_dir/logs-only"
mkdir -p "$logs_only_project/logs"
if "$script_dir/init_latex_project.sh" "$source_pdf" "$logs_only_project" standard >/dev/null 2>&1; then
  printf 'Expected scaffold initialization to reject a logs-only target directory.\n' >&2
  exit 1
fi

if "$script_dir/init_latex_project.sh" "$source_pdf" "$tmp_dir/bad-delivery" standard "camera ready" >/dev/null 2>&1; then
  printf 'Expected scaffold initialization to reject an unsupported delivery level.\n' >&2
  exit 1
fi

resumable_project="$tmp_dir/resumable"
mkdir -p "$resumable_project"
printf 'existing main\n' >"$resumable_project/main.tex"
printf '# Existing State\n' >"$resumable_project/conversion-state.md"
"$script_dir/init_latex_project.sh" "$source_pdf" "$resumable_project" standard >/dev/null
if [[ $(cat "$resumable_project/main.tex") != 'existing main' ]]; then
  printf 'Expected scaffold initialization to preserve existing resumable project files.\n' >&2
  exit 1
fi

"$script_dir/init_latex_project.sh" "$source_pdf" "$scaffold_project" book-math "publication polish" >/dev/null

for expected in \
  main.tex \
  conversion-state.md \
  conversion-notes.md \
  page-manifest.md \
  object-inventory.md \
  style-profile.md \
  document-ir.md \
  math-inventory.md \
  glyph-map.md \
  frontmatter \
  backmatter \
  evidence/source-pages \
  evidence/rebuilt-pages \
  evidence/crops \
  evidence/text-layer \
  logs; do
  if [[ ! -e "$scaffold_project/$expected" ]]; then
    printf 'Scaffold smoke test missing expected path: %s\n' "$expected" >&2
    exit 1
  fi
done

if grep -Fq 'Page 001: pending' "$scaffold_project/page-manifest.md"; then
  printf 'Expected page manifest template to avoid a fake Page 001 route.\n' >&2
  exit 1
fi

upgrade_project="$tmp_dir/upgrade-project"
"$script_dir/init_latex_project.sh" "$source_pdf" "$upgrade_project" light >/dev/null
for unexpected in \
  page-manifest.md \
  object-inventory.md \
  style-profile.md \
  document-ir.md \
  math-inventory.md \
  glyph-map.md \
  chapters \
  figures \
  tables \
  transcripts \
  evidence; do
  if [[ -e "$upgrade_project/$unexpected" ]]; then
    printf 'Light scaffold should not create heavy path by default: %s\n' "$unexpected" >&2
    exit 1
  fi
done
if [[ ! -d "$upgrade_project/logs" ]]; then
  printf 'Light scaffold should still create logs directory.\n' >&2
  exit 1
fi
printf 'user-authored IR\n' >"$upgrade_project/document-ir.md"
"$script_dir/upgrade_latex_project.sh" "$upgrade_project" book-math >/dev/null

for expected in \
  page-manifest.md \
  object-inventory.md \
  style-profile.md \
  document-ir.md \
  math-inventory.md \
  glyph-map.md \
  frontmatter \
  backmatter; do
  if [[ ! -e "$upgrade_project/$expected" ]]; then
    printf 'Profile upgrade smoke test missing expected path: %s\n' "$expected" >&2
    exit 1
  fi
done

if [[ $(cat "$upgrade_project/document-ir.md") != 'user-authored IR' ]]; then
  printf 'Expected profile upgrade to preserve existing files.\n' >&2
  exit 1
fi

if "$script_dir/upgrade_latex_project.sh" "$upgrade_project" camera-ready >/dev/null 2>&1; then
  printf 'Expected profile upgrade to reject unsupported profiles.\n' >&2
  exit 1
fi

delivery_upgrade_project="$tmp_dir/delivery-upgrade-project"
mkdir -p "$delivery_upgrade_project"
printf '\\documentclass{article}\\begin{document}Upgrade\\end{document}\\n' >"$delivery_upgrade_project/main.tex"
printf 'Source PDF: %s\nDelivery level: polish\n' "$source_pdf" >"$delivery_upgrade_project/conversion-state.md"
"$script_dir/upgrade_latex_project.sh" "$delivery_upgrade_project" standard >/dev/null
if ! grep -Fq 'Delivery level: publication polish' "$delivery_upgrade_project/conversion-notes.md"; then
  printf 'Expected profile upgrade to normalize inferred delivery level.\n' >&2
  exit 1
fi

if ! grep -Fq 'Current phase: scaffold created' "$scaffold_project/conversion-state.md"; then
  printf 'Expected scaffold state to record scaffold created phase.\n' >&2
  exit 1
fi

if ! grep -Fq -- '- [x] Project scaffold created' "$scaffold_project/conversion-state.md"; then
  printf 'Expected scaffold state to mark project scaffold checkpoint complete.\n' >&2
  exit 1
fi

if ! grep -Fq -- '- [ ] Initial triage complete' "$scaffold_project/conversion-state.md"; then
  printf 'Expected scaffold state to include the initial triage checkpoint.\n' >&2
  exit 1
fi

if ! grep -Fq 'Delivery level: publication polish' "$scaffold_project/conversion-state.md"; then
  printf 'Expected scaffold state to record the requested delivery level.\n' >&2
  exit 1
fi

if ! grep -Fq 'Delivery level: publication polish' "$scaffold_project/conversion-notes.md"; then
  printf 'Expected scaffold notes to record the requested delivery level.\n' >&2
  exit 1
fi

if ! grep -Fq 'scripts/init_latex_project.sh' "$scaffold_project/conversion-state.md"; then
  printf 'Expected scaffold state to record initialization command.\n' >&2
  exit 1
fi

if "$script_dir/render_pdf_pages.sh" "$source_pdf" "$tmp_dir/render-dpi-zero" 0 >/dev/null 2>&1; then
  printf 'Expected page rendering to reject zero DPI.\n' >&2
  exit 1
fi

if command -v xelatex >/dev/null 2>&1 && { command -v pdftoppm >/dev/null 2>&1 || command -v mutool >/dev/null 2>&1; }; then
  real_source_dir="$tmp_dir/real-source"
  real_project="$tmp_dir/real-project"
  mkdir -p "$real_source_dir"
  printf '\\documentclass{article}\\begin{document}Real PDF smoke test.\\end{document}\\n' >"$real_source_dir/source.tex"

  if (cd "$real_source_dir" && xelatex -interaction=nonstopmode -halt-on-error source.tex >/dev/null 2>&1); then
    sample_project="$tmp_dir/sample-project"
    "$script_dir/init_latex_project.sh" "$real_source_dir/source.pdf" "$sample_project" standard >/dev/null
    if ! grep -Fq 'Delivery level: clean semantic' "$sample_project/conversion-state.md"; then
      printf 'Expected default delivery level to be clean semantic.\n' >&2
      exit 1
    fi
    "$script_dir/render_pdf_pages.sh" "$real_source_dir/source.pdf" "$sample_project" 80 --pages 1 >/dev/null
    if [[ ! -f "$sample_project/evidence/source-pages/page-001.png" ]]; then
      printf 'Expected selected source page rendering to create page-001.png.\n' >&2
      exit 1
    fi
    if command -v pdftotext >/dev/null 2>&1; then
      "$script_dir/extract_text_pages.sh" "$real_source_dir/source.pdf" "$sample_project" --pages 1 >/dev/null
      if [[ ! -f "$sample_project/evidence/text-layer/page-001.txt" ]]; then
        printf 'Expected selected text extraction to create page-001.txt.\n' >&2
        exit 1
      fi
      if ! grep -Fq 'Real PDF smoke test.' "$sample_project/evidence/text-layer/page-001.txt"; then
        printf 'Expected extracted page text to contain sample PDF text.\n' >&2
        exit 1
      fi
      if "$script_dir/extract_text_pages.sh" "$real_source_dir/source.pdf" "$sample_project" --pages 1 >/dev/null 2>&1; then
        printf 'Expected text extraction to refuse overwriting selected evidence without --force.\n' >&2
        exit 1
      fi
      "$script_dir/extract_text_pages.sh" "$real_source_dir/source.pdf" "$sample_project" --pages 1 --force >/dev/null
    fi
    if "$script_dir/render_pdf_pages.sh" "$real_source_dir/source.pdf" "$sample_project" 80 --pages 1 >/dev/null 2>&1; then
      printf 'Expected selected page rendering to refuse overwriting without --force.\n' >&2
      exit 1
    fi
    "$script_dir/render_pdf_pages.sh" "$real_source_dir/source.pdf" "$sample_project" 80 --pages 1 --force >/dev/null

    "$script_dir/init_latex_project.sh" "$real_source_dir/source.pdf" "$real_project" standard >/dev/null
    "$script_dir/render_pdf_pages.sh" "$real_source_dir/source.pdf" "$real_project" 80 >/dev/null

    if "$script_dir/render_pdf_pages.sh" "$real_source_dir/source.pdf" "$real_project" 80 >/dev/null 2>&1; then
      printf 'Expected page rendering to refuse overwriting existing evidence without --force.\n' >&2
      exit 1
    fi

    "$script_dir/render_pdf_pages.sh" "$real_source_dir/source.pdf" "$real_project" 80 --force >/dev/null
    "$script_dir/latex_healthcheck.sh" "$real_project" main.tex >/dev/null
    "$script_dir/render_rebuilt_pages.sh" "$real_project" main.pdf 80 >/dev/null
    if [[ ! -f "$real_project/evidence/rebuilt-pages/page-001.png" ]]; then
      printf 'Expected rebuilt page rendering to create page-001.png.\n' >&2
      exit 1
    fi
    if "$script_dir/render_rebuilt_pages.sh" "$real_project" main.pdf 80 --from 1 --to 1 >/dev/null 2>&1; then
      printf 'Expected rebuilt page rendering to refuse overwriting selected evidence without --force.\n' >&2
      exit 1
    fi
    "$script_dir/render_rebuilt_pages.sh" "$real_project" main.pdf 80 --from 1 --to 1 --force >/dev/null
    "$script_dir/check_latex_artifacts.sh" "$real_project" >/dev/null

    nested_project="$tmp_dir/nested-project"
    mkdir -p "$nested_project/src"
    printf '\\documentclass{article}\\begin{document}Nested main.\\end{document}\\n' >"$nested_project/src/main.tex"
    "$script_dir/latex_healthcheck.sh" "$nested_project" src/main.tex >/dev/null
    if [[ ! -f "$nested_project/main.pdf" ]]; then
      printf 'Expected nested main healthcheck to find the generated root-level PDF.\n' >&2
      exit 1
    fi
  else
    printf 'Skipping real PDF smoke tests because xelatex failed to generate a sample PDF.\n' >&2
  fi
else
  printf 'Skipping real PDF smoke tests because xelatex and a PDF renderer are not both available.\n' >&2
fi

printf 'Skill helper smoke tests passed.\n'
