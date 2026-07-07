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

clean_project="$tmp_dir/clean"
dirty_project="$tmp_dir/dirty"
empty_project="$tmp_dir/empty"
mkdir -p "$clean_project/chapters" "$dirty_project/chapters" "$empty_project"

printf '\\documentclass{article}\\begin{document}Clean\\end{document}\\n' >"$clean_project/main.tex"
printf 'This source contains no blocking extraction artifacts.\\n' >"$clean_project/chapters/content.tex"

printf '\\documentclass{article}\\begin{document}\\pdfglyph{bad}\\end{document}\\n' >"$dirty_project/main.tex"

"$script_dir/check_latex_artifacts.sh" "$clean_project" >/dev/null

if "$script_dir/check_latex_artifacts.sh" "$dirty_project" >/dev/null 2>&1; then
  printf 'Expected artifact scan to fail for dirty project.\n' >&2
  exit 1
fi

"$script_dir/check_latex_artifacts.sh" "$empty_project" >/dev/null

source_pdf="$tmp_dir/source.pdf"
scaffold_project="$tmp_dir/scaffold"
printf 'placeholder pdf bytes for scaffold smoke test\n' >"$source_pdf"
"$script_dir/init_latex_project.sh" "$source_pdf" "$scaffold_project" book-math >/dev/null

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
  evidence/source-pages \
  evidence/rebuilt-pages \
  evidence/crops \
  logs; do
  if [[ ! -e "$scaffold_project/$expected" ]]; then
    printf 'Scaffold smoke test missing expected path: %s\n' "$expected" >&2
    exit 1
  fi
done

printf 'Skill helper smoke tests passed.\n'
