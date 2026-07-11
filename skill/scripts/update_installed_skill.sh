#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s [--ref REF]\n' "$0" >&2
  printf 'Fast-install or update pdf-to-latex from GitHub; REF defaults to development branch main.\n' >&2
}

is_pdf_to_latex_installation() {
  python3 - "$1/SKILL.md" <<'PY'
import pathlib
import re
import sys

try:
    lines = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8").splitlines()
except (OSError, UnicodeDecodeError):
    raise SystemExit(1)

if not lines or lines[0].strip() != "---":
    raise SystemExit(1)

name_pattern = re.compile(r"name:\s*(?:pdf-to-latex|'pdf-to-latex'|\"pdf-to-latex\")\s*")
found_name = False
for line in lines[1:]:
    if line.strip() == "---":
        raise SystemExit(0 if found_name else 1)
    if name_pattern.fullmatch(line.strip()):
        found_name = True
raise SystemExit(1)
PY
}

ref=main
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref)
      if [[ $# -lt 2 || -z "$2" || "$2" == -* ]]; then
        usage
        exit 2
      fi
      ref=$2
      shift 2
      ;;
    --ref=*)
      ref=${1#--ref=}
      if [[ -z "$ref" || "$ref" == -* ]]; then
        usage
        exit 2
      fi
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

export PYTHONDONTWRITEBYTECODE=1

codex_home=${CODEX_HOME:-$HOME/.codex}
skills_dir="$codex_home/skills"
skill_dir="$skills_dir/pdf-to-latex"
installer=${PDF_TO_LATEX_INSTALLER:-$skills_dir/.system/skill-installer/scripts/install-skill-from-github.py}
lock_dir="$skills_dir/.pdf-to-latex.install.lock"
staging_root=
rollback_root=
rollback=
lock_active=false
rollback_active=false
committed=false

cleanup() {
  status=$?
  trap - EXIT HUP INT TERM
  set +e

  if [[ "$rollback_active" == true && "$committed" != true && -d "$rollback" ]]; then
    if rm -rf "$skill_dir"; then
      if mv "$rollback" "$skill_dir"; then
        rollback_active=false
      else
        printf 'Failed to restore the previous installation from: %s\n' "$rollback" >&2
        status=1
      fi
    else
      printf 'Failed to remove the incomplete installation at: %s\n' "$skill_dir" >&2
      printf 'Previous installation retained at: %s\n' "$rollback" >&2
      status=1
    fi
  fi

  if [[ -n "$staging_root" ]]; then
    rm -rf "$staging_root" || status=1
  fi
  if [[ -n "$rollback_root" ]]; then
    if [[ "$committed" == true || "$rollback_active" != true || ! -d "$rollback" ]]; then
      rm -rf "$rollback_root" || status=1
    fi
  fi
  if [[ "$lock_active" == true ]]; then
    rmdir "$lock_dir" 2>/dev/null || status=1
  fi
  exit "$status"
}

trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

if [[ ! -f "$installer" ]]; then
  printf 'Codex skill installer not found: %s\n' "$installer" >&2
  exit 1
fi

mkdir -p "$skills_dir"
if ! mkdir "$lock_dir" 2>/dev/null; then
  printf 'Another pdf-to-latex install or update is active: %s\n' "$lock_dir" >&2
  exit 1
fi
lock_active=true

if [[ -L "$skill_dir" ]]; then
  printf 'Installed skill path must be a real directory, not a symlink: %s\n' "$skill_dir" >&2
  exit 1
fi
if [[ -e "$skill_dir" && ! -d "$skill_dir" ]]; then
  printf 'Installed skill path is not a directory: %s\n' "$skill_dir" >&2
  exit 1
fi
if [[ -d "$skill_dir" ]] && ! is_pdf_to_latex_installation "$skill_dir"; then
  printf 'Refusing to replace a directory that is not an installed pdf-to-latex skill: %s\n' "$skill_dir" >&2
  exit 1
fi

staging_root=$(mktemp -d "$skills_dir/.pdf-to-latex.update.XXXXXX")

python3 "$installer" \
  --url https://github.com/zuchengchen/pdf-to-latex \
  --path skill \
  --ref "$ref" \
  --dest "$staging_root" \
  --name pdf-to-latex \
  --method download

fresh="$staging_root/pdf-to-latex"
if [[ ! -f "$fresh/SKILL.md" ]]; then
  printf 'Downloaded skill is missing SKILL.md: %s\n' "$fresh" >&2
  exit 1
fi

for helper in "$fresh"/scripts/*.sh "$fresh"/scripts/*.py; do
  if [[ -f "$helper" ]]; then
    chmod 755 "$helper"
  fi
done

python3 "$fresh/scripts/workflow_contract.py" validate-package "$fresh"

cd "$skills_dir"
action=Installed
if [[ -d "$skill_dir" ]]; then
  rollback_root=$(mktemp -d "$skills_dir/.pdf-to-latex.rollback.XXXXXX")
  rollback="$rollback_root/installed"
  rollback_active=true
  mv "$skill_dir" "$rollback"
  action=Updated
fi

if ! mv "$fresh" "$skill_dir"; then
  printf 'Failed to place the staged skill at: %s\n' "$skill_dir" >&2
  exit 1
fi
committed=true

if [[ "$rollback_active" == true ]]; then
  rm -rf "$rollback_root"
  rollback_active=false
fi

printf '%s pdf-to-latex from ref %s at %s\n' "$action" "$ref" "$skill_dir"
printf 'Start a new Codex session to load the updated skill.\n'
