# PDF to LaTeX Skill

`pdf-to-latex` is a Codex Agent Skill for automatically rebuilding PDFs as editable XeLaTeX projects, compiling the result, and refining the generated LaTeX until the output is semantically complete and readable. It is designed for semantic reconstruction: preserve document structure, readable content, formulas, tables, figures, captions, and references rather than trying to recreate every page pixel-for-pixel.

This is a workflow skill. It does not ship a CLI, bundled conversion scripts, local OCR dependency, or cloud OCR dependency. Codex uses the instructions in `SKILL.md` and `references/` together with local PDF tools and visual reasoning.

## Quick Install

In Codex, enter:

```text
安装skill https://github.com/zuchengchen/pdf-to-latex
```

If Codex asks for details, choose:

- GitHub URL: `https://github.com/zuchengchen/pdf-to-latex`
- Skill path inside repo: `.`
- Skill name: `pdf-to-latex`

If GitHub archive download is rate-limited, ask Codex to install with a normal `git clone` fallback into `${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex`.

After installation, restart Codex so the new skill is discovered.

## Quick Update

On a machine where this skill is already installed, ask Codex:

```text
更新 skill https://github.com/zuchengchen/pdf-to-latex.git
```

Codex should update `${CODEX_HOME:-$HOME/.codex}/skills/pdf-to-latex` in place with `git pull --ff-only` when it is a Git checkout. If the installed directory is not a Git checkout, Codex should back it up and clone a fresh copy from GitHub. Restart Codex after updating so the new skill instructions are loaded.

## What It Does

- Inspects digital, scanned, or mixed PDFs.
- Splits or renders PDFs into page-level evidence for Codex visual transcription.
- Uses optional `pdftotext` extraction only for digital PDF text layers.
- Rebuilds the document as a maintainable XeLaTeX project.
- For scanned PDFs, uses Codex visual recognition to rebuild semantic content instead of embedding full-page screenshots by default.
- Automatically runs compile-review-polish loops after the first generated draft.
- De-pages rough transcripts into normal document structure and idiomatic LaTeX.
- Maintains `conversion-state.md` so interrupted conversions can resume from the latest checkpoint.
- Defaults to creating a `latex/` directory next to the source PDF.
- Uses `main.tex`, optional `chapters/`, `figures/`, `tables/`, `transcripts/`, `page-manifest.md`, `conversion-state.md`, and `conversion-notes.md`.
- Records uncertain, inferred, approximated, or web-supplemented content.
- Compiles, reviews, and polishes the output PDF for semantic completeness and readability.

## Repository Structure

```text
pdf-to-latex/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── references/
│   ├── latex-rebuild.md
│   ├── latex-refinement.md
│   ├── pdf-analysis.md
│   └── quality-review.md
├── INSTALL.md
└── README.md
```

`SKILL.md` is the trigger and workflow entry point. The detailed procedures live in the `references/` files so Codex can load only the guidance it needs.

## Dependencies

The skill itself has no package manager dependencies.

Useful local tools for actual PDF-to-LaTeX work include:

- XeLaTeX or `latexmk -xelatex`
- Poppler tools such as `pdftotext`, `pdfinfo`, `pdfseparate`, `pdftoppm`, or `pdfimages`
- Optional renderer alternatives such as `mutool draw`

The skill is written so Codex uses visual recognition for scanned pages. Do not use local OCR engines such as `tesseract` or `ocrmypdf`. Rendered page images are analysis inputs, not the default LaTeX output.

## Usage Example

After installing and restarting Codex:

```text
$pdf-to-latex 把 ./paper.pdf 重排成可编辑 LaTeX 项目，并编译出 PDF
```

Codex should create a `latex/` directory next to `paper.pdf`, maintain `conversion-notes.md`, compile with XeLaTeX, run the minimum refinement passes, and report any uncertain reconstruction.
It should also maintain `conversion-state.md` so a later Codex session can continue from the latest completed checkpoint.

For an existing generated project:

```text
$pdf-to-latex 对照 ./paper.pdf 自动精修 ./latex，并重新编译输出 PDF
```

To resume interrupted work:

```text
$pdf-to-latex 继续 ./latex 里上次中断的 PDF 转 LaTeX 任务
```

## More Installation Options

See [INSTALL.md](INSTALL.md) for exact Codex installer parameters, manual installation, update, uninstall, and troubleshooting notes.
