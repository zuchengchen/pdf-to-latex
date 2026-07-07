# Installation

This repository contains a Codex skill under `skill/`. The repository root is not the skill root; it only contains publishing docs and development notes.

## Install From Codex

Recommended prompt:

```text
安装 skill https://github.com/zuchengchen/pdf-to-latex，path 使用 skill，名称使用 pdf-to-latex
```

When Codex uses the GitHub skill installer, use these values:

- Repo: `zuchengchen/pdf-to-latex`
- URL: `https://github.com/zuchengchen/pdf-to-latex`
- Path inside repo: `skill`
- Destination skill name: `pdf-to-latex`
- Default destination: `${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex`

Equivalent installer command:

```bash
python "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-installer/scripts/install-skill-from-github.py" \
  --url https://github.com/zuchengchen/pdf-to-latex \
  --path skill \
  --name pdf-to-latex
```

Restart Codex after installation.

## Manual User-Level Install

Use HTTPS:

```bash
tmp_dir="$(mktemp -d)"
git clone https://github.com/zuchengchen/pdf-to-latex.git "$tmp_dir/pdf-to-latex"
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
cp -R "$tmp_dir/pdf-to-latex/skill" "${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
```

Or SSH:

```bash
tmp_dir="$(mktemp -d)"
git clone git@github.com:zuchengchen/pdf-to-latex.git "$tmp_dir/pdf-to-latex"
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
cp -R "$tmp_dir/pdf-to-latex/skill" "${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
```

Then restart Codex.

## Verify Installation

Check that the skill file exists:

```bash
test -f "${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex/SKILL.md"
```

Start a new Codex session and type `$` to see whether `pdf-to-latex` appears. You can also invoke it directly:

```text
$pdf-to-latex 把这个 PDF 重排成 LaTeX 项目
```

## Update

Recommended Codex prompt:

```text
更新 skill https://github.com/zuchengchen/pdf-to-latex.git，path 使用 skill
```

Manual update:

```bash
skill_dir="${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
backup="${skill_dir}.backup.$(date +%Y%m%d%H%M%S)"
tmp_dir="$(mktemp -d)"

git clone https://github.com/zuchengchen/pdf-to-latex.git "$tmp_dir/pdf-to-latex"
if [[ -d "$skill_dir" ]]; then
  mv "$skill_dir" "$backup"
fi
cp -R "$tmp_dir/pdf-to-latex/skill" "$skill_dir"
```

Restart Codex after updating.

## Uninstall

```bash
rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
```

Restart Codex after uninstalling.

## Troubleshooting

If a direct install prompt does not infer the skill path automatically, ask Codex explicitly:

```text
安装 skill https://github.com/zuchengchen/pdf-to-latex，仓库中的 skill 目录才是 skill 根目录，path 使用 skill，名称使用 pdf-to-latex
```

If GitHub archive download is rate-limited, ask Codex to use a normal Git clone fallback and copy only the `skill/` directory into `${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex`.

Do not install the repository root directly as a skill. The required `SKILL.md` file is under `skill/SKILL.md`.

If installation says the destination already exists, use the Update section above. The GitHub skill installer is installation-oriented and may abort instead of overwriting an existing skill directory.

If the skill installs but does not appear, restart Codex and confirm that `SKILL.md` exists under `${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex/`.
