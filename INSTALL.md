# Installation

This repository is a Codex skill whose skill root is the repository root. The required `SKILL.md` file is at the top level.

## Install From Codex

The intended installation prompt is:

```text
安装skill https://github.com/zuchengchen/pdf-to-latex
```

Equivalent wording with a space is also fine:

```text
安装 skill https://github.com/zuchengchen/pdf-to-latex
```

When Codex uses the GitHub skill installer, this repository should be installed from the repo root:

- Repo: `zuchengchen/pdf-to-latex`
- URL: `https://github.com/zuchengchen/pdf-to-latex`
- Path inside repo: `.`
- Destination skill name: `pdf-to-latex`
- Default destination: `${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex`

The equivalent installer command is:

```bash
python "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-installer/scripts/install-skill-from-github.py" \
  --url https://github.com/zuchengchen/pdf-to-latex \
  --path . \
  --name pdf-to-latex
```

Restart Codex after installation.

## Manual User-Level Install

Use HTTPS:

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
git clone https://github.com/zuchengchen/pdf-to-latex.git "${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
```

Or SSH:

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
git clone git@github.com:zuchengchen/pdf-to-latex.git "${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
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
更新 skill https://github.com/zuchengchen/pdf-to-latex.git
```

If using SSH credentials, this form is also fine:

```text
更新 skill git@github.com:zuchengchen/pdf-to-latex.git
```

Prefer the full `https://github.com/...` or `git@github.com:...` URL over the abbreviated `github.com:owner/repo.git` form so Codex can parse the repository unambiguously.

If the installed skill directory is a Git checkout, update it in place:

```bash
SKILL_DIR="${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
git -C "$SKILL_DIR" remote set-url origin https://github.com/zuchengchen/pdf-to-latex.git
git -C "$SKILL_DIR" pull --ff-only
```

If the installed skill directory exists but is not a Git checkout, back it up and clone a fresh copy:

```bash
SKILL_DIR="${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
BACKUP="${SKILL_DIR}.backup.$(date +%Y%m%d%H%M%S)"

mv "$SKILL_DIR" "$BACKUP"
git clone https://github.com/zuchengchen/pdf-to-latex.git "$SKILL_DIR"
```

If the directory does not exist yet, install it normally:

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
git clone https://github.com/zuchengchen/pdf-to-latex.git "${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
```

Restart Codex after updating or reinstalling.

## Uninstall

```bash
rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
```

Restart Codex after uninstalling.

## Troubleshooting

If a direct install prompt does not infer the repo root automatically, ask Codex explicitly:

```text
安装 skill https://github.com/zuchengchen/pdf-to-latex，仓库根目录就是 skill 目录，path 使用 .，名称使用 pdf-to-latex
```

If GitHub archive download is rate-limited, ask Codex to use a normal Git clone fallback instead of sparse installer git mode:

```text
安装 skill https://github.com/zuchengchen/pdf-to-latex；如果安装器下载被 GitHub 限流，请 git clone 到 ${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex
```

Do not use sparse installer git mode with `--path .` for this repo; it can fetch only top-level files and omit `agents/` and `references/`.

If installation says the destination already exists, use the Update section above. The GitHub skill installer is installation-oriented and may abort instead of overwriting an existing skill directory.

If the skill installs but does not appear, restart Codex and confirm that `SKILL.md` exists under `${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex/`.
