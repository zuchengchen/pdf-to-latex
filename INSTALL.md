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

If installed with Git:

```bash
cd "${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex"
git pull --ff-only
```

Restart Codex after updating.

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

If installation says the destination already exists, remove the existing directory or update it with `git pull`.

If the skill installs but does not appear, restart Codex and confirm that `SKILL.md` exists under `${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex/`.
