---
name: pdf-to-latex
description: "Use when Codex needs to convert, rebuild, re-typeset, or recreate a PDF as an editable LaTeX or XeLaTeX project and compiled PDF, including digital PDFs, scanned PDFs, reports, papers, figures, tables, formulas, references, OCR or visual page review, semantic restructuring, compilation, and quality checks."
---

# PDF to LaTeX

## Purpose

Use this skill to rebuild a user-provided PDF into an editable LaTeX project and a compiled PDF. Prioritize semantic structure, readability, and maintainable LaTeX over pixel-perfect recreation.

Codex performs the conversion work directly with local tools, visual reasoning, and LaTeX editing. This skill does not provide or require a bundled CLI, `scripts/` directory, installer, or cloud OCR API.

## Reference Routing

- Read `references/pdf-analysis.md` before inspecting or transcribing the source PDF.
- Read `references/latex-rebuild.md` before creating or editing the LaTeX project.
- Read `references/quality-review.md` before compiling, reviewing, or delivering the result.

## Default Output Contract

For a conversion task, create a `latex/` directory next to the source PDF unless the user gives another location. Do not silently overwrite an existing `latex/` directory; ask the user or choose a clearly named alternative after approval.

Default project layout:

```text
latex/
├── main.tex
├── chapters/
├── figures/
├── tables/
└── conversion-notes.md
```

Small documents may use fewer subdirectories, but explain the simplification in `conversion-notes.md`.

## Workflow

1. Confirm the source PDF path and target output location.
2. Inspect the PDF type, page count, text layer, images, tables, formulas, references, and any scanned pages using `references/pdf-analysis.md`.
3. Build a semantic outline before writing LaTeX: title, authors or metadata, sections, body flow, figures, tables, formulas, citations, and appendices.
4. Create the LaTeX project with XeLaTeX as the default engine using `references/latex-rebuild.md`.
5. Mark uncertain or reconstructed content in both the LaTeX source and `conversion-notes.md`; do not present guesses as exact transcription.
6. Compile and review the result using `references/quality-review.md`.
7. Deliver the project path, compiled PDF path, verification performed, and remaining uncertainties.

## Conversion Rules

- Prefer semantic rebuilding over visual tracing. Preserve meaning, reading order, headings, formulas, tables, figures, captions, references, and clear layout.
- For scanned pages, prefer Codex visual reasoning from rendered page images. Use local OCR tools such as `tesseract` or `ocrmypdf` only as helpful supplements when available.
- Use public web lookup only when it helps identify public metadata, citations, public versions, standard formulas, or source context. Label web-sourced additions separately from PDF-derived content.
- Use XeLaTeX by default, especially for Unicode, multilingual text, and CJK documents.
- Keep LaTeX maintainable: use packages intentionally, split long content into chapters or sections, and avoid brittle absolute positioning unless the user explicitly requests visual recreation.
- Continue through content uncertainty when a reasonable approximation is possible, but clearly mark approximations, missing details, and inferred material.

## Stop And Ask

Ask the user before proceeding when:

- The source PDF path is missing or ambiguous.
- The target `latex/` directory already exists and proceeding may overwrite user work.
- A required system tool for the requested verification is missing and cannot be used.
- The user asks for a bundled converter, CLI, script package, skill installation, or cloud OCR dependency, because those are outside this skill's design.
- A newer user instruction conflicts with this skill's output contract.
