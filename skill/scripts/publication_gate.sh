#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s [PROJECT_DIR] [MAIN_TEX] [--skip-render] [--skip-clean] [--strict-findings] [--render-dpi DPI] [--pages LIST | --from N --to M]\n' "$0" >&2
  printf 'Runs deterministic publication gates: compile, artifact scan, optional render, text extraction, and clean rebuild.\n' >&2
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

skip_render=false
skip_clean=false
strict_findings=false
render_dpi=140
render_args=()
positional=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-render)
      skip_render=true
      shift
      ;;
    --skip-clean)
      skip_clean=true
      shift
      ;;
    --strict-findings)
      strict_findings=true
      shift
      ;;
    --render-dpi)
      [[ $# -ge 2 ]] || die 'Missing value for --render-dpi.'
      render_dpi=$2
      shift 2
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

if [[ ${#positional[@]} -gt 2 ]]; then
  usage
  exit 2
fi

project_dir=${positional[0]:-.}
main_tex=${positional[1]:-main.tex}

[[ -d "$project_dir" ]] || die "Project directory not found: $project_dir"
[[ -f "$project_dir/$main_tex" ]] || die "Main TeX file not found: $project_dir/$main_tex"
positive_int "$render_dpi" || die "Render DPI must be a positive integer: $render_dpi"

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
project_dir=$(cd -- "$project_dir" && pwd)
mkdir -p "$project_dir/logs"
gate_log="$project_dir/logs/publication_gate.log"
summary_file="$project_dir/logs/publication_gate_summary.txt"
: >"$gate_log"
: >"$summary_file"

run_step() {
  local label=$1
  shift

  printf '== %s ==\n' "$label" | tee -a "$gate_log"
  set +e
  "$@" > >(tee -a "$gate_log") 2> >(tee -a "$gate_log" >&2)
  local status=$?
  set -e
  if [[ $status -ne 0 ]]; then
    printf 'FAIL: %s\n' "$label" | tee -a "$summary_file" "$gate_log" >&2
    exit "$status"
  fi
  printf 'PASS: %s\n' "$label" | tee -a "$summary_file" "$gate_log"
}

check_strict_findings() {
  local checked_project=$1
  local label=$2
  local findings_file="$checked_project/logs/latex_healthcheck_findings.txt"
  local strict_pattern='Undefined control sequence|LaTeX Warning:.*undefined|Citation .* undefined|Reference .* undefined|There were undefined references|Rerun to get cross-references right|Package .* Error|File .* not found'

  [[ "$strict_findings" == true ]] || return

  printf '== Strict findings check: %s ==\n' "$label" | tee -a "$gate_log"

  if [[ ! -f "$findings_file" ]]; then
    printf 'FAIL: Strict findings check missing %s\n' "$findings_file" | tee -a "$summary_file" "$gate_log" >&2
    exit 1
  fi

  if grep -E "$strict_pattern" "$findings_file" | tee -a "$gate_log"; then
    printf 'FAIL: Strict findings check: %s\n' "$label" | tee -a "$summary_file" "$gate_log" >&2
    exit 1
  fi

  if grep -E 'Overfull \\hbox|Overfull \\vbox' "$findings_file" | tee -a "$gate_log"; then
    printf 'WARN: Strict findings check saw overfull boxes for %s; review typography.\n' "$label" | tee -a "$summary_file" "$gate_log"
  fi

  printf 'PASS: Strict findings check: %s\n' "$label" | tee -a "$summary_file" "$gate_log"
}

find_compiled_pdf() {
  local main_base=${main_tex##*/}
  local expected="$project_dir/${main_base%.tex}.pdf"
  local candidates=()

  if [[ -f "$expected" ]]; then
    printf '%s\n' "$expected"
    return
  fi

  shopt -s nullglob
  candidates=("$project_dir"/*.pdf)
  shopt -u nullglob
  if [[ ${#candidates[@]} -eq 1 ]]; then
    printf '%s\n' "${candidates[0]}"
    return
  fi

  return 1
}

run_step "XeLaTeX healthcheck" "$script_dir/latex_healthcheck.sh" "$project_dir" "$main_tex"
check_strict_findings "$project_dir" "primary build"
run_step "Final source artifact scan" "$script_dir/check_latex_artifacts.sh" "$project_dir"

compiled_pdf=$(find_compiled_pdf) || die 'Could not identify compiled PDF after healthcheck.'
compiled_pdf_name=${compiled_pdf##*/}

if [[ "$skip_render" != true ]]; then
  run_step "Rendered rebuilt page evidence" "$script_dir/render_rebuilt_pages.sh" "$project_dir" "$compiled_pdf_name" "$render_dpi" --force "${render_args[@]}"
else
  printf 'SKIP: Rendered rebuilt page evidence\n' | tee -a "$summary_file" "$gate_log"
fi

if command -v pdftotext >/dev/null 2>&1; then
  run_step "Compiled PDF text extraction" pdftotext "$compiled_pdf" "$project_dir/logs/publication_gate_output.txt"
else
  printf 'SKIP: Compiled PDF text extraction (pdftotext unavailable)\n' | tee -a "$summary_file" "$gate_log"
fi

cleanup_dir=
cleanup() {
  if [[ -n "${cleanup_dir:-}" ]]; then
    rm -rf "$cleanup_dir"
  fi
}
trap cleanup EXIT

if [[ "$skip_clean" != true ]]; then
  cleanup_dir=$(mktemp -d)
  clean_project="$cleanup_dir/project"
  mkdir -p "$clean_project"

  (
    cd "$project_dir"
    tar --exclude='./logs/publication_gate.log' \
      --exclude='./logs/publication_gate_summary.txt' \
      --exclude='./logs/publication_gate_output.txt' \
      -cf - .
  ) | (
    cd "$clean_project"
    tar -xf -
  )

  find "$clean_project" -type f \( \
    -name '*.aux' -o -name '*.log' -o -name '*.out' -o -name '*.toc' \
    -o -name '*.lof' -o -name '*.lot' -o -name '*.fls' -o -name '*.fdb_latexmk' \
    -o -name '*.synctex.gz' -o -name '*.bbl' -o -name '*.blg' -o -name '*.bcf' \
    -o -name '*.run.xml' -o -name '*.idx' -o -name '*.ilg' -o -name '*.ind' \
    -o -name '*.glg' -o -name '*.glo' -o -name '*.gls' -o -name '*.ist' \
  \) -delete
  rm -f -- "$clean_project/$compiled_pdf_name"

  run_step "Clean-room XeLaTeX rebuild" "$script_dir/latex_healthcheck.sh" "$clean_project" "$main_tex"
  check_strict_findings "$clean_project" "clean-room build"
else
  printf 'SKIP: Clean-room XeLaTeX rebuild\n' | tee -a "$summary_file" "$gate_log"
fi

printf 'Publication gate passed. Summary: %s\n' "$summary_file"
