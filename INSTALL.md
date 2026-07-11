# Installation

The installable Codex skill is the repository's `skill/` directory. Do not
install the repository root.

## Stable Codex Install

Use the canonical GitHub URL without a `.git` suffix:

```text
安装 skill https://github.com/zuchengchen/pdf-to-latex，ref 使用 v1.0.0，path 使用 skill，名称使用 pdf-to-latex
```

Equivalent command:

```bash
python3 "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-installer/scripts/install-skill-from-github.py" \
  --url https://github.com/zuchengchen/pdf-to-latex \
  --ref v1.0.0 \
  --path skill \
  --name pdf-to-latex
```

The installer is for a new destination and should stop when
`${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex` already exists. Use the update
procedure below for an existing installation.

Restart Codex after installation.

## Fast Codex Update

After installing a version that contains `scripts/update_installed_skill.sh`,
the normal update command is:

```text
更新 skill pdf-to-latex
```

The skill routes this exact command to its bundled updater instead of the
conversion workflow or the conservative atomic procedure below. The bare
command updates from the development branch `main`; use
`更新 skill pdf-to-latex 到 REF` for a tag, branch, or commit.

The fast path uses Codex's system GitHub installer in download mode, writes into
same-filesystem staging, restores executable bits, runs exactly one bundled
package validation, and swaps directories by rename with rollback. It does not
run `quick_validate.py`, `bash -n`, portable, integration, or extended tests.
Those checks belong in repository CI and release validation.

The equivalent direct command from an existing installed copy is:

```bash
skill_dir="${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
bash "$skill_dir/scripts/update_installed_skill.sh" --ref main
```

An older installation that does not contain the updater must use the system
installer or Atomic Update once. Restart Codex or start a new session after the
fast update.

## Manual Prerequisites

The manual install and update procedures require Git, Python 3.10+, Bash 3.2+,
and an existing Codex installation that provides the trusted skill validator at
`${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py`.

## Atomic Manual Install

This procedure validates a staged copy before placing it at the final path. It
never overwrites an existing installation.

```bash
set -euo pipefail

codex_home=${CODEX_HOME:-$HOME/.codex}
skills_dir="$codex_home/skills"
skill_dir="$skills_dir/pdf-to-latex"
ref=v1.0.0
tmp_dir=$(mktemp -d)
staging=
lock_dir="$skills_dir/.pdf-to-latex.install.lock"
lock_active=false
validator="$codex_home/skills/.system/skill-creator/scripts/quick_validate.py"

cleanup() {
  status=$?
  trap - EXIT HUP INT TERM
  set +e
  if ! rm -rf "$tmp_dir"; then
    printf 'Failed to remove temporary repository: %s\n' "$tmp_dir" >&2
    status=1
  fi
  if [[ -n "$staging" ]]; then
    if ! rm -rf "$staging"; then
      printf 'Failed to remove staging directory: %s\n' "$staging" >&2
      status=1
    fi
  fi
  if [[ "$lock_active" == true ]]; then
    if ! rmdir "$lock_dir" 2>/dev/null; then
      printf 'Failed to release install lock: %s\n' "$lock_dir" >&2
      status=1
    fi
  fi
  exit "$status"
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

if [[ ! -f "$validator" ]]; then
  printf 'Trusted Codex skill validator not found: %s\n' "$validator" >&2
  exit 1
fi

mkdir -p "$skills_dir"
if ! mkdir "$lock_dir" 2>/dev/null; then
  printf 'Another pdf-to-latex install or update is active: %s\n' "$lock_dir" >&2
  exit 1
fi
lock_active=true
if [[ -e "$skill_dir" || -L "$skill_dir" ]]; then
  printf 'Destination already exists; use the update procedure: %s\n' "$skill_dir" >&2
  exit 1
fi
staging=$(mktemp -d "$skills_dir/.pdf-to-latex.staging.XXXXXX")
git clone --depth 1 --branch "$ref" \
  https://github.com/zuchengchen/pdf-to-latex \
  "$tmp_dir/repository"

source_skill="$tmp_dir/repository/skill"
python3 "$validator" "$source_skill"
bash -n "$source_skill"/scripts/*.sh
python3 "$source_skill/scripts/workflow_contract.py" validate-package "$source_skill"

cp -R "$source_skill"/. "$staging"/
python3 "$staging/scripts/workflow_contract.py" validate-package "$staging"
mv "$staging" "$skill_dir"
```

## Atomic Update

The update uses unique same-filesystem staging and rollback directories. It
attempts to restore the old installation after any failure or interruption
before final package validation succeeds. A successful update or restoration
removes the rollback immediately. If restoration itself fails, cleanup retains
the rollback path and prints it for manual recovery.

```bash
set -euo pipefail

codex_home=${CODEX_HOME:-$HOME/.codex}
skills_dir="$codex_home/skills"
skill_dir="$skills_dir/pdf-to-latex"
ref=v1.0.0
tmp_dir=$(mktemp -d)
staging=
rollback_root=
rollback=
lock_dir="$skills_dir/.pdf-to-latex.install.lock"
validator="$codex_home/skills/.system/skill-creator/scripts/quick_validate.py"
lock_active=false
rollback_active=false
committed=false

cleanup() {
  status=$?
  trap - EXIT HUP INT TERM
  set +e
  if ! rm -rf "$tmp_dir"; then
    printf 'Failed to remove temporary repository: %s\n' "$tmp_dir" >&2
    status=1
  fi
  if [[ -n "$staging" ]]; then
    if ! rm -rf "$staging"; then
      printf 'Failed to remove staging directory: %s\n' "$staging" >&2
      status=1
    fi
  fi
  if [[ "$rollback_active" == true && "$committed" != true && -d "$rollback" ]]; then
    if rm -rf "$skill_dir" && mv "$rollback" "$skill_dir"; then
      rollback_active=false
    else
      printf 'Failed to restore the previous installation from: %s\n' "$rollback" >&2
      status=1
    fi
  fi
  if [[ -n "$rollback_root" ]]; then
    if [[ "$committed" == true || "$rollback_active" != true || ! -d "$rollback" ]]; then
      if ! rm -rf "$rollback_root"; then
        printf 'Failed to remove rollback directory: %s\n' "$rollback_root" >&2
        status=1
      fi
    fi
  fi
  if [[ "$lock_active" == true ]]; then
    if ! rmdir "$lock_dir" 2>/dev/null; then
      printf 'Failed to release install lock: %s\n' "$lock_dir" >&2
      status=1
    fi
  fi
  exit "$status"
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

if [[ ! -f "$validator" ]]; then
  printf 'Trusted Codex skill validator not found: %s\n' "$validator" >&2
  exit 1
fi

if ! mkdir "$lock_dir" 2>/dev/null; then
  printf 'Another pdf-to-latex install or update is active: %s\n' "$lock_dir" >&2
  exit 1
fi
lock_active=true
if [[ -L "$skill_dir" ]]; then
  printf 'Installed skill path must be a real directory, not a symlink: %s\n' "$skill_dir" >&2
  exit 1
fi
if [[ ! -d "$skill_dir" ]]; then
  printf 'Installed skill not found; use the install procedure: %s\n' "$skill_dir" >&2
  exit 1
fi

staging=$(mktemp -d "$skills_dir/.pdf-to-latex.staging.XXXXXX")
rollback_root=$(mktemp -d "$skills_dir/.pdf-to-latex.rollback.XXXXXX")
rollback="$rollback_root/installed"

git clone --depth 1 --branch "$ref" \
  https://github.com/zuchengchen/pdf-to-latex \
  "$tmp_dir/repository"

source_skill="$tmp_dir/repository/skill"
python3 "$validator" "$source_skill"
bash -n "$source_skill"/scripts/*.sh
python3 "$source_skill/scripts/workflow_contract.py" validate-package "$source_skill"

cp -R "$source_skill"/. "$staging"/
python3 "$staging/scripts/workflow_contract.py" validate-package "$staging"
rollback_active=true
mv "$skill_dir" "$rollback"
mv "$staging" "$skill_dir"
python3 "$skill_dir/scripts/workflow_contract.py" validate-package "$skill_dir"
committed=true
rm -rf "$rollback_root"
rollback_active=false
```

Restart Codex after updating.

## Development Channel

To test unreleased changes, replace `v1.0.0` with `main`. Development installs
are not the stable channel and may contain contract changes.

## Verify Installation

Run the installed package validator:

```bash
skill_dir="${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
python3 "$skill_dir/scripts/workflow_contract.py" validate-package "$skill_dir"
```

Then start a new Codex session, type `$`, and confirm that `pdf-to-latex`
appears. A direct invocation is:

```text
$pdf-to-latex 把这个 PDF 重建成可编辑 LaTeX 项目
```

## Uninstall

```bash
rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
```

Restart Codex after uninstalling.

## Troubleshooting

- Use `https://github.com/zuchengchen/pdf-to-latex`, not a `.git` URL, with the
  Codex GitHub installer.
- Pass `--path skill`; the repository root does not contain the installable
  `SKILL.md`.
- If the destination exists, use the atomic update procedure instead of asking
  the installer to overwrite it.
- Manual install and update reject a symlink destination and serialize through
  `.pdf-to-latex.install.lock`. Remove that directory only after confirming no
  install or update process is still running.
- If an update reports that restoration failed, keep the printed
  `.pdf-to-latex.rollback.*` directory until its `installed/` copy has been
  restored or inspected manually.
- If archive download is rate-limited, the manual Git procedure remains safe
  because it validates staging before moving the installed directory.
- Python 3.10+ is required by deterministic workflow helpers.
