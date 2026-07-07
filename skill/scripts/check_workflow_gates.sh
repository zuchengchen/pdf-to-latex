#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s [PROJECT_DIR] [--delivery-level LEVEL] [--allow-blocked]\n' "$0" >&2
  printf 'Checks resumable workflow state files for required PDF-to-LaTeX gates.\n' >&2
}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

normalize_delivery_level() {
  case "$1" in
    "rough draft"|rough|rough-draft)
      printf 'rough draft\n'
      ;;
    "clean semantic"|clean|clean-semantic|"")
      printf 'clean semantic\n'
      ;;
    "publication polish"|publication|publication-polish|polish)
      printf 'publication polish\n'
      ;;
    *)
      return 1
      ;;
  esac
}

read_field() {
  local field=$1
  local file=$2

  if [[ -f "$file" ]]; then
    sed -n "s/^$field:[[:space:]]*//p" "$file" | head -n 1
  fi
}

positional=()
delivery_override=
allow_blocked=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --delivery-level)
      [[ $# -ge 2 ]] || die 'Missing value for --delivery-level.'
      delivery_override=$2
      shift 2
      ;;
    --allow-blocked)
      allow_blocked=true
      shift
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

if [[ ${#positional[@]} -gt 1 ]]; then
  usage
  exit 2
fi

project_dir=${positional[0]:-.}
[[ -d "$project_dir" ]] || die "Project directory not found: $project_dir"

project_dir=$(cd -- "$project_dir" && pwd)
state_file="$project_dir/conversion-state.md"
notes_file="$project_dir/conversion-notes.md"

failures=0
warnings=0

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  failures=$((failures + 1))
}

warn() {
  printf 'WARN: %s\n' "$*" >&2
  warnings=$((warnings + 1))
}

pass() {
  printf 'PASS: %s\n' "$*"
}

require_file() {
  local path=$1
  if [[ -f "$project_dir/$path" ]]; then
    pass "Found $path"
  else
    fail "Missing required file: $path"
  fi
}

optional_dir() {
  local path=$1
  if [[ -d "$project_dir/$path" ]]; then
    pass "Found $path/"
  else
    warn "Optional directory not found: $path"
  fi
}

require_section() {
  local section=$1
  if grep -Fq "$section" "$notes_file"; then
    pass "Notes include $section"
  else
    fail "conversion-notes.md missing section: $section"
  fi
}

checkpoint_complete() {
  local label=$1
  grep -Fq -- "- [x] $label" "$state_file"
}

require_checkpoint() {
  local label=$1
  if checkpoint_complete "$label"; then
    pass "Checkpoint complete: $label"
    return
  fi

  if [[ "$allow_blocked" == true ]] && grep -Eiq 'blocked|blocker|阻塞|未解决' "$notes_file"; then
    warn "Checkpoint not complete but blockers are documented: $label"
  else
    fail "Checkpoint is not complete: $label"
  fi
}

gate_value() {
  local label=$1
  local line
  local value

  while IFS= read -r line; do
    case "$line" in
      "$label:"*)
        value=${line#"$label:"}
        value=${value#"${value%%[![:space:]]*}"}
        printf '%s\n' "$value"
        return
        ;;
    esac
  done <"$notes_file"
}

require_acceptance_gate() {
  local label=$1
  local allow_na=${2:-false}
  local value

  value=$(gate_value "$label")
  case "$value" in
    pass)
      pass "Acceptance gate passed: $label"
      ;;
    blocked)
      if [[ "$allow_blocked" == true ]]; then
        warn "Acceptance gate blocked and allowed: $label"
      else
        fail "Acceptance gate is blocked: $label"
      fi
      ;;
    "not applicable")
      if [[ "$allow_na" == true ]]; then
        pass "Acceptance gate not applicable: $label"
      else
        fail "Acceptance gate cannot be not applicable: $label"
      fi
      ;;
    "")
      fail "Acceptance gate has no value: $label"
      ;;
    *)
      fail "Acceptance gate has unsupported value for $label: $value"
      ;;
  esac
}

scan_unfinished_statuses() {
  local file=$1
  local path="$project_dir/$file"

  [[ -f "$path" ]] || return

  if grep -Fq 'No page routes recorded yet.' "$path"; then
    fail "$file still contains the empty scaffold page-route marker."
  fi

  if grep -nE 'status:[[:space:]]*$|status:[[:space:]]*(pending|in-progress)[[:space:]]*$|\|[[:space:]]*status:[[:space:]]*(pending|in-progress)([[:space:]]|$)' "$path"; then
    if [[ "$allow_blocked" == true ]] && grep -Eiq 'blocked|blocker|阻塞|未解决' "$notes_file"; then
      warn "$file contains unfinished statuses but blockers are documented."
    else
      fail "$file contains blank, pending, or in-progress statuses."
    fi
  fi
}

require_file main.tex
require_file conversion-state.md
require_file conversion-notes.md
require_section '## Goal Mode Planning'
require_checkpoint 'Goal mode planning complete'

delivery_level=$delivery_override
if [[ -z "$delivery_level" ]]; then
  delivery_level=$(read_field 'Delivery level' "$state_file")
fi
if [[ -z "$delivery_level" ]]; then
  delivery_level=$(read_field 'Delivery level' "$notes_file")
fi
if ! delivery_level=$(normalize_delivery_level "$delivery_level"); then
  fail "Unsupported or missing delivery level: ${delivery_override:-unknown}"
  delivery_level=unknown
fi
printf 'Delivery level: %s\n' "$delivery_level"

task_profile=$(read_field 'Task profile' "$state_file")
if [[ -z "$task_profile" ]]; then
  task_profile=$(read_field 'Task profile' "$notes_file")
fi
task_profile=${task_profile:-unknown}
printf 'Task profile: %s\n' "$task_profile"

case "$task_profile" in
  light|standard|book|math-heavy|book-math|unknown) ;;
  *)
    fail "Unsupported task profile: $task_profile"
    ;;
esac

if [[ "$task_profile" != light && "$task_profile" != unknown ]]; then
  require_file page-manifest.md
  require_file object-inventory.md
  require_file style-profile.md
  require_file document-ir.md
fi

case "$task_profile" in
  math-heavy|book-math)
    require_file math-inventory.md
    require_file glyph-map.md
    ;;
esac

case "$task_profile" in
  book|book-math)
    optional_dir frontmatter
    optional_dir backmatter
    ;;
esac

if [[ "$delivery_level" == "publication polish" ]]; then
  if [[ "$task_profile" == unknown ]]; then
    fail 'Publication polish requires a recorded task profile.'
  fi

  require_file page-manifest.md
  require_file object-inventory.md
  require_file style-profile.md
  require_file document-ir.md

  require_section '## Delivery Contract'
  require_section '## Production Spec'
  require_section '## Source Completeness Audit'
  require_section '## Asset Discovery'
  require_section '## Reviewer Gates'
  require_section '## Quality Review'
  require_section 'Publication-polish acceptance gates:'

  require_checkpoint 'Delivery contract gate complete when applicable'
  require_checkpoint 'Production spec gate complete when applicable'
  require_checkpoint 'Source completeness audit complete when applicable'
  require_checkpoint 'Skeleton compile gate complete'
  require_checkpoint 'Asset discovery gate complete'
  require_checkpoint 'Midpoint reviewer gate complete when applicable'
  require_checkpoint 'Batch compile gate complete'
  require_checkpoint 'Final publication reviewer gates complete when applicable'
  require_checkpoint 'Clean-room build gate complete'
  require_checkpoint 'Quality review complete'

  require_acceptance_gate 'Goal mode planning'
  require_acceptance_gate 'Delivery contract'
  require_acceptance_gate 'Production spec'
  require_acceptance_gate 'Source completeness audit'
  require_acceptance_gate 'Skeleton compile'
  require_acceptance_gate 'Asset discovery'
  require_acceptance_gate 'Batch compile history'
  require_acceptance_gate 'Midpoint reviewer'
  require_acceptance_gate 'Final structure/content reviewer'
  require_acceptance_gate 'Final math/object reviewer' true
  require_acceptance_gate 'Final build/layout reviewer'
  require_acceptance_gate 'Visual comparison'
  require_acceptance_gate 'Artifact scan' true
  require_acceptance_gate 'Clean-room build'
  require_acceptance_gate 'Final notes/state'

  scan_unfinished_statuses page-manifest.md
  scan_unfinished_statuses object-inventory.md
  scan_unfinished_statuses document-ir.md
  scan_unfinished_statuses math-inventory.md
fi

if [[ "$failures" -gt 0 ]]; then
  printf 'Workflow gate check failed with %s failure(s) and %s warning(s).\n' "$failures" "$warnings" >&2
  exit 1
fi

printf 'Workflow gate check passed with %s warning(s).\n' "$warnings"
