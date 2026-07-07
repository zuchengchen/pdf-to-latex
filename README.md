# PDF to LaTeX Skill

`pdf-to-latex` is a Codex Agent Skill for rebuilding PDFs as editable XeLaTeX projects, compiling the result, and refining the generated LaTeX until it is semantically complete, readable, and maintainable. It favors semantic reconstruction over pixel-perfect page tracing: preserve structure, text, formulas, tables, figures, captions, references, and book-scale apparatus when present.

The installable skill lives in [`skill/`](skill/). The repository root contains human-facing docs and development notes only.

This is a workflow skill, not a bundled PDF-to-LaTeX converter. It does include reusable templates and small helper scripts for project scaffolding, repeatable page rendering, LaTeX compile health checks, and artifact scans. It does not require local OCR engines or cloud OCR APIs.

## Quick Install

In Codex, enter:

```text
安装 skill https://github.com/zuchengchen/pdf-to-latex，path 使用 skill，名称使用 pdf-to-latex
```

If Codex asks for details, choose:

- GitHub URL: `https://github.com/zuchengchen/pdf-to-latex`
- Skill path inside repo: `skill`
- Skill name: `pdf-to-latex`

After installation, restart Codex so the new skill is discovered.

## Quick Update

On a machine where this skill is already installed, ask Codex:

```text
更新 skill https://github.com/zuchengchen/pdf-to-latex.git，path 使用 skill
```

Restart Codex after updating so the new skill instructions are loaded.

## What It Does

- Chooses exact `light`, `standard`, `book`, `math-heavy`, or `book-math` workflow profiles to avoid overloading simple tasks while supporting specialized long or formula-heavy conversions.
- Inspects digital, scanned, mixed, encoded, and damaged-text PDFs.
- Renders durable page evidence under `latex/evidence/source-pages/` for visual transcription and later resume, with page-list and page-range batching for long PDFs.
- Uses optional page-bounded `pdftotext` extraction under `latex/evidence/text-layer/` only for digital PDF text-layer evidence.
- Builds document IR, object inventory, and style profile when the selected profile needs them.
- Detects academic/technical book, textbook, monograph, proceedings, thesis, dissertation, and long manual structures.
- Tracks math-heavy reconstruction with `math-inventory.md` and `glyph-map.md` when formulas or encoded symbols need focused cleanup.
- Creates consistent project scaffolds from bundled templates when starting a new conversion, including book front/back matter directories and math tracking files for the relevant profiles.
- Rebuilds the document as a maintainable XeLaTeX project rather than scanned page screenshots.
- Uses rough draft, clean semantic, and publication polish delivery levels so simple tasks can finish without book-scale overhead.
- Runs compile-review-polish loops after the first generated draft unless the user explicitly asks for a rough draft.
- Maintains `conversion-state.md` and `conversion-notes.md` so interrupted conversions can resume from the latest checkpoint.
- Uses helper scripts in `skill/scripts/` for scaffolding, rendering source or rebuilt pages, checking LaTeX health, scanning final source for extraction artifacts, and smoke testing the skill package.

## Repository Structure

```text
pdf-to-latex/
├── .github/
│   └── workflows/
│       └── validate.yml
├── README.md
├── INSTALL.md
├── dev-goals/
│   └── ...
└── skill/
    ├── SKILL.md
    ├── agents/
    │   └── openai.yaml
    ├── assets/
    │   └── templates/
    │       └── ...
    ├── references/
    │   ├── book-production.md
    │   ├── goal-mode.md
    │   ├── latex-rebuild.md
    │   ├── latex-refinement.md
    │   ├── math-polish.md
    │   ├── pdf-analysis.md
    │   └── quality-review.md
    └── scripts/
        ├── check_latex_artifacts.sh
        ├── init_latex_project.sh
        ├── latex_healthcheck.sh
        ├── render_pdf_pages.sh
        ├── render_rebuilt_pages.sh
        └── test_skill.sh
```

`skill/SKILL.md` is the trigger and workflow entry point. Detailed procedures live in `skill/references/` so Codex can load only the guidance it needs.

## Dependencies

The skill has no package manager dependencies.

Useful local tools for actual PDF-to-LaTeX work include:

- XeLaTeX or `latexmk -xelatex`
- Poppler tools such as `pdftotext`, `pdfinfo`, `pdfseparate`, `pdftoppm`, or `pdfimages`
- Optional renderer alternatives such as `mutool draw`

The skill is written so Codex uses visual recognition for scanned pages. Do not use local OCR engines such as `tesseract` or `ocrmypdf`. Rendered page images are analysis inputs, not the default LaTeX output.

## Known Limitations

- This skill guides Codex through reconstruction; it is not a one-command converter and does not bundle a PDF-to-LaTeX engine.
- Long, scanned, damaged-text, or math-heavy PDFs may need multiple resumable passes before the result is clean.
- Scanned pages are meant to be visually transcribed into semantic LaTeX. Full-page screenshots are not the normal final output.
- Pixel-perfect reproduction is outside the default goal. The normal target is editable, readable, semantically faithful XeLaTeX.
- Public web lookup may be used only for metadata, citations, public source context, or standard formulas, and should be documented separately from PDF-derived content.

## Development Validation

Run the full local smoke suite after changing the skill:

```bash
skill/scripts/test_skill.sh
```

The smoke suite validates skill metadata when the Codex system validator is available, checks shell syntax, exercises artifact scanning, verifies scaffold guardrails, and runs a real PDF render/compile smoke test when local TeX and PDF rendering tools are available. The repository also includes a GitHub Actions workflow that runs the portable checks on push and pull request.

## Usage Examples

After installing and restarting Codex:

```text
$pdf-to-latex 把 ./paper.pdf 重排成可编辑 LaTeX 项目，并编译出 PDF
```

For an academic or technical book:

```text
$pdf-to-latex 把 "Quantum Field Theory for the Gifted Amateur.pdf" 转成latex
```

For an existing generated project:

```text
$pdf-to-latex 对照 ./paper.pdf 自动精修 ./latex，并重新编译输出 PDF
```

To resume interrupted work:

```text
$pdf-to-latex 继续 ./latex 里上次中断的 PDF 转 LaTeX 任务
```

## More Installation Options

See [INSTALL.md](INSTALL.md) for exact installer parameters, manual installation, update, uninstall, and troubleshooting notes.
