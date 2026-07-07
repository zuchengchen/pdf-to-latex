#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s [PROJECT_DIR] [MAIN_TEX]\n' "$0" >&2
  printf 'Compiles a XeLaTeX project and summarizes key log findings.\n' >&2
}

if [[ $# -gt 2 ]]; then
  usage
  exit 2
fi

project_dir=${1:-.}
main_tex=${2:-main.tex}

if [[ ! -d "$project_dir" ]]; then
  printf 'Project directory not found: %s\n' "$project_dir" >&2
  exit 1
fi

cd "$project_dir"

if [[ ! -f "$main_tex" ]]; then
  printf 'Main TeX file not found: %s\n' "$main_tex" >&2
  exit 1
fi

mkdir -p logs
log_file="logs/latex_healthcheck.log"
findings_file="logs/latex_healthcheck_findings.txt"
pdf_file="${main_tex%.tex}.pdf"

if command -v latexmk >/dev/null 2>&1; then
  if ! latexmk -xelatex -interaction=nonstopmode -halt-on-error "$main_tex" >"$log_file" 2>&1; then
    printf 'XeLaTeX compile failed. See %s\n' "$log_file" >&2
    tail -n 80 "$log_file" >&2 || true
    exit 1
  fi
elif command -v xelatex >/dev/null 2>&1; then
  if ! xelatex -interaction=nonstopmode -halt-on-error "$main_tex" >"$log_file" 2>&1; then
    printf 'XeLaTeX compile failed. See %s\n' "$log_file" >&2
    tail -n 80 "$log_file" >&2 || true
    exit 1
  fi
  if ! xelatex -interaction=nonstopmode -halt-on-error "$main_tex" >>"$log_file" 2>&1; then
    printf 'Second XeLaTeX pass failed. See %s\n' "$log_file" >&2
    tail -n 80 "$log_file" >&2 || true
    exit 1
  fi
else
  printf 'Missing compiler: install latexmk or xelatex.\n' >&2
  exit 1
fi

grep -E 'Undefined control sequence|LaTeX Warning:.*undefined|Citation .* undefined|Reference .* undefined|There were undefined references|Rerun to get cross-references right|Package .* Error|LaTeX Font Warning|File .* not found|Overfull \\hbox|Overfull \\vbox' "$log_file" >"$findings_file" || true

if [[ -f "$pdf_file" ]]; then
  printf 'Output PDF: %s\n' "$pdf_file"
else
  printf 'Warning: compile command succeeded but expected PDF was not found: %s\n' "$pdf_file" >&2
fi

if [[ -s "$findings_file" ]]; then
  printf 'Compile succeeded with findings in %s:\n' "$findings_file"
  cat "$findings_file"
else
  printf 'Compile succeeded; no key findings captured in %s\n' "$findings_file"
fi
