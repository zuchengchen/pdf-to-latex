#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s [PROJECT_DIR]\n' "$0" >&2
  printf 'Scans final LaTeX source for PDF extraction artifacts.\n' >&2
}

if [[ $# -gt 1 ]]; then
  usage
  exit 2
fi

project_dir=${1:-.}
if [[ ! -d "$project_dir" ]]; then
  printf 'Project directory not found: %s\n' "$project_dir" >&2
  exit 1
fi

cd "$project_dir"

paths=()
for path in main.tex chapters tables frontmatter backmatter; do
  [[ -e "$path" ]] && paths+=("$path")
done

if [[ ${#paths[@]} -eq 0 ]]; then
  printf 'No standard final-source paths found in %s\n' "$project_dir" >&2
  exit 0
fi

pattern='\\pdfglyph|extracteddisplay|TODO math|unresolved glyph|raw glyph|MATH_PLACEHOLDER'

if command -v rg >/dev/null 2>&1; then
  if rg -n "$pattern" "${paths[@]}"; then
    printf 'Artifact scan found blocking matches.\n' >&2
    exit 1
  fi
else
  if grep -RInE "$pattern" "${paths[@]}"; then
    printf 'Artifact scan found blocking matches.\n' >&2
    exit 1
  fi
fi

printf 'Artifact scan clean.\n'
