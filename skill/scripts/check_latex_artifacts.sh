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
while IFS= read -r -d '' path; do
  paths+=("${path#./}")
done < <(
  find . \
    \( -path './logs' -o -path './logs/*' \
       -o -path './evidence' -o -path './evidence/*' \
       -o -path './transcripts' -o -path './transcripts/*' \) -prune \
    -o -type f \( -name '*.tex' -o -name '*.bib' \) -print0
)

if [[ ${#paths[@]} -eq 0 ]]; then
  printf 'No LaTeX source or bibliography files found in %s\n' "$project_dir" >&2
  exit 1
fi

pattern='\\pdfglyph|extracteddisplay|TODO[[:space:]_-]*math|unresolved[[:space:]_-]+glyph|MATH_PLACEHOLDER|%.*raw[[:space:]_-]+glyph|raw[[:space:]_-]+glyph[[:space:]]*:|math[[:space:]_-]*placeholder'

if command -v rg >/dev/null 2>&1; then
  if rg -n "$pattern" "${paths[@]}"; then
    printf 'Artifact scan found blocking matches.\n' >&2
    exit 1
  else
    status=$?
    if [[ $status -ne 1 ]]; then
      printf 'Artifact scan failed while searching final source paths.\n' >&2
      exit "$status"
    fi
  fi
else
  if grep -RInE "$pattern" "${paths[@]}"; then
    printf 'Artifact scan found blocking matches.\n' >&2
    exit 1
  else
    status=$?
    if [[ $status -ne 1 ]]; then
      printf 'Artifact scan failed while searching final source paths.\n' >&2
      exit "$status"
    fi
  fi
fi

printf 'Artifact scan clean.\n'
