# PDF to LaTeX Skill

`pdf-to-latex` is a Codex Agent Skill for rebuilding PDFs as editable XeLaTeX projects and compiled PDFs. It is designed for semantic reconstruction: preserve document structure, readable content, formulas, tables, figures, captions, and references rather than trying to recreate every page pixel-for-pixel.

This is a workflow skill. It does not ship a CLI, bundled conversion scripts, or a cloud OCR dependency. Codex uses the instructions in `SKILL.md` and `references/` together with local tools and visual reasoning.

## Quick Install

In Codex, enter:

```text
安装skill https://github.com/zuchengchen/pdf-to-latex
```

If Codex asks for details, choose:

- GitHub URL: `https://github.com/zuchengchen/pdf-to-latex`
- Skill path inside repo: `.`
- Skill name: `pdf-to-latex`

After installation, restart Codex so the new skill is discovered.

## What It Does

- Inspects digital, scanned, or mixed PDFs.
- Guides Codex through rendered page review and visual/OCR reasoning.
- Rebuilds the document as a maintainable XeLaTeX project.
- Defaults to creating a `latex/` directory next to the source PDF.
- Uses `main.tex`, optional `chapters/`, `figures/`, `tables/`, and `conversion-notes.md`.
- Records uncertain, inferred, approximated, or web-supplemented content.
- Compiles and reviews the output PDF for semantic completeness and readability.

## Repository Structure

```text
pdf-to-latex/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── references/
│   ├── latex-rebuild.md
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
- Poppler tools such as `pdftotext`, `pdfinfo`, `pdftoppm`, or `pdfimages`
- Optional OCR tools such as `tesseract` or `ocrmypdf`

The skill is written so Codex can use visual reasoning first for scanned pages and local OCR as a supplement when available.

## Usage Example

After installing and restarting Codex:

```text
$pdf-to-latex 把 ./paper.pdf 重排成可编辑 LaTeX 项目，并编译出 PDF
```

Codex should create a `latex/` directory next to `paper.pdf`, maintain `conversion-notes.md`, compile with XeLaTeX, and report any uncertain reconstruction.

## More Installation Options

See [INSTALL.md](INSTALL.md) for exact Codex installer parameters, manual installation, update, uninstall, and troubleshooting notes.
