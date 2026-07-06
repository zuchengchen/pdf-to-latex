---
name: pdf-to-latex
description: "Use when Codex needs to automatically convert, rebuild, re-typeset, refine, polish, repair, or improve a PDF as an editable LaTeX or XeLaTeX project and compiled PDF, including digital PDFs, scanned PDFs, generated LaTeX cleanup, iterative refinement, compile fixes, layout cleanup, figures, tables, formulas, references, Codex visual page transcription, semantic restructuring, compilation, and quality checks."
---

# PDF to LaTeX

## Purpose

Use this skill to rebuild a user-provided PDF into an editable LaTeX project, compile it, and refine the generated LaTeX until the result is semantically complete, readable, and maintainable. Prioritize semantic structure and practical polish over pixel-perfect recreation.

Codex performs the conversion work directly with local tools, visual reasoning, and LaTeX editing. This skill does not provide or require a bundled CLI, `scripts/` directory, installer, local OCR engine, or cloud OCR API. Use local PDF tools for metadata, page splitting, page rendering, digital text-layer extraction, asset extraction, and LaTeX compilation only.

## Reference Routing

- Read `references/pdf-analysis.md` before inspecting or transcribing the source PDF.
- Read `references/latex-rebuild.md` before creating or editing the LaTeX project.
- Read `references/latex-refinement.md` before polishing generated LaTeX, fixing compile or layout issues, or comparing the rebuilt PDF against the source.
- Read `references/quality-review.md` before compiling, reviewing, or delivering the result.

## Default Output Contract

For a conversion task, create a `latex/` directory next to the source PDF unless the user gives another location. Do not silently overwrite an unrelated existing `latex/` directory. When the directory contains a resumable project, continue it; otherwise ask the user or choose a clearly named alternative after approval.

Default project layout:

```text
latex/
├── main.tex
├── chapters/
├── figures/
├── tables/
├── transcripts/
├── page-manifest.md
├── conversion-state.md
└── conversion-notes.md
```

Small documents may use fewer subdirectories, but explain the simplification in `conversion-notes.md`. Keep page-level transcripts or fragments when they are useful for review, resume, or subagent integration.

Always maintain `conversion-state.md` as the resumable checkpoint file. Keep it concise and update it whenever a milestone completes or the next action changes. It should include:

```text
Source PDF:
Target directory:
Last updated:
Current phase:
Completed checkpoints:
Last successful command:
Active files:
Next action:
Blockers or uncertainties:
```

Use `conversion-notes.md` for richer evidence, decisions, commands, and unresolved details; use `conversion-state.md` for fast restart.

## Automatic Conversion And Refinement Workflow

1. Confirm the source PDF path and target output location. If the target exists, first inspect it for `conversion-state.md`, `conversion-notes.md`, `main.tex`, LaTeX logs, and compiled PDFs.
2. When a resumable project is found, continue from `conversion-state.md`'s `Next action`. If the state file is missing but project artifacts exist, infer the current phase from available files and logs, create `conversion-state.md`, and resume without overwriting work.
3. Inspect the PDF type, page count, text layer, images, tables, formulas, references, and any scanned pages using `references/pdf-analysis.md`. Classify pages or regions as digital, scanned, mixed, or damaged-text, then update the state file after analysis.
4. Split or render the source into page-level evidence. Prefer per-page images for Codex visual transcription; keep single-page PDFs only when they help asset extraction or page-specific inspection.
5. Create `page-manifest.md` with the page or region route map. For digital pages only, `pdftotext` may be used as optional text-layer evidence; never use local OCR engines.
6. Use Codex visual recognition to transcribe each page or page batch into semantic LaTeX fragments under `transcripts/` or equivalent notes. Use subagents for independent page batches only when the current environment and user instructions permit parallel agent work.
7. Build a semantic outline before writing final LaTeX: title, authors or metadata, sections, body flow, figures, tables, formulas, citations, and appendices. Record the outline checkpoint and next action.
8. Create the LaTeX project with XeLaTeX as the default engine using `references/latex-rebuild.md`. Merge page fragments into coherent chapters and update the state file with created files and active gaps.
9. Compile the generated project and inspect errors, warnings, rendered pages, extracted text, `conversion-state.md`, and `conversion-notes.md`. Record compile success or the first hard failure.
10. Run the multi-pass polish loop in `references/latex-refinement.md`: fix compile issues, remove page-transcript artifacts, improve document structure, convert rough text into idiomatic LaTeX objects, tune typography, and visually compare rendered output. Update the state file after each focused pass.
11. Repeat review and refinement until the rebuilt PDF passes the quality gates or the remaining issues are explicitly marked as unresolved. Do not deliver the first compiling PDF as final unless the user explicitly requested only a rough draft.
12. Deliver the project path, compiled PDF path, verification performed, refinements made, and remaining uncertainties.

If the user provides an existing generated LaTeX project, skip initial reconstruction and start at step 9. Treat refinement as part of the default job, not as a separate optional follow-up.

## Codex Visual Transcription Workflow

For scanned, mixed, damaged-text, or visually complex PDFs, follow this normal path:

1. Render pages at practical analysis resolution and keep those images as page-level evidence.
2. Give Codex the rendered page image, optional neighboring-page context, and optional digital text-layer excerpt when the page is digital.
3. Transcribe each page into structured semantic LaTeX fragments, especially headings, paragraphs, formulas, tables, captions, footnotes, and references.
4. Mark page starts, page ends, cross-page continuations, figure/table needs, and uncertain symbols or text.
5. Build a semantic outline from the page transcripts and visual page review.
6. Write LaTeX as editable text, math, semantic tables, citations, and cropped real figures only.
7. Compile and refine the semantic LaTeX. If a region is unreadable, leave a concise placeholder and document the uncertainty instead of embedding the scanned page.

Do not use `tesseract`, `ocrmypdf`, local OCR engines, or cloud OCR APIs. Do not use full-page scanned screenshots as a compile shortcut. They are expensive, uneditable, and outside the default purpose of this skill.

## Resume Behavior

Before doing substantial work, read `conversion-state.md` when it exists. Trust explicit user instructions over the state file, but otherwise use the state file to avoid repeating completed analysis, transcription, extraction, compile fixes, or review passes.

If `conversion-state.md` and project artifacts disagree, verify the filesystem and logs, then update the state file to match reality before continuing. Preserve user edits in the target project; when unsure whether a file is generated or user-authored, inspect it and record the decision.

Write a state update before ending a long turn, after each successful compile, after each failed compile diagnosis, and after each meaningful refinement pass. A future Codex agent should be able to resume by reading only `conversion-state.md`, then loading the referenced notes, logs, and files.

## Conversion Rules

- Prefer semantic rebuilding over visual tracing. Preserve meaning, reading order, headings, formulas, tables, figures, captions, references, and clear layout.
- For every scanned or visually complex page, use Codex visual recognition from rendered page images as the transcription source. Do not use local OCR.
- For digital PDFs, `pdftotext` may be used only as optional text-layer evidence. Codex visual review remains responsible for reading order, formulas, tables, captions, footnotes, and extraction correction.
- For scanned PDFs, rebuild normal LaTeX content: visually transcribe text into paragraphs and sections, convert formulas into math, rebuild legible tables semantically, and include only genuine figures or diagrams as cropped figure assets.
- Use public web lookup only when it helps identify public metadata, citations, public versions, standard formulas, or source context. Label web-sourced additions separately from PDF-derived content.
- Use XeLaTeX by default, especially for Unicode, multilingual text, and CJK documents.
- Keep LaTeX maintainable: use packages intentionally, split long content into chapters or sections, and avoid brittle absolute positioning unless the user explicitly requests visual recreation.
- Make small, reviewable refinement edits. Compile after each focused batch before moving to the next class of issues.
- Continue through content uncertainty when a reasonable approximation is possible, but clearly mark approximations, missing details, and inferred material.
- When scanned content cannot be reliably read, insert a concise semantic placeholder or source comment and document the gap in `conversion-notes.md`; do not use full-page screenshots to make the PDF compile.

## Stop And Ask

Ask the user before proceeding when:

- The source PDF path is missing or ambiguous.
- The target `latex/` directory already exists, has no recoverable state or recognizable project artifacts, and proceeding may overwrite user work.
- A required system tool for the requested verification is missing and cannot be used.
- The user asks for a bundled converter, CLI, script package, skill installation, local OCR dependency, or cloud OCR dependency, because those are outside this skill's design.
- A newer user instruction conflicts with this skill's output contract.
