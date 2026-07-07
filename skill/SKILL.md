---
name: pdf-to-latex
description: "Use when Codex needs to convert a user-provided PDF into an editable LaTeX or XeLaTeX project, rebuild or refine a PDF-derived LaTeX project, compile the result, and run semantic quality review. Handles digital, scanned, mixed, math-heavy, book-scale, thesis, and technical PDFs. Not for generic PDF editing, signing, compression, page rearrangement, form filling, or extraction-only tasks unless the goal is LaTeX reconstruction."
---

# PDF to LaTeX

## Purpose

Use this skill to rebuild a user-provided PDF into an editable LaTeX project, compile it, and refine the generated LaTeX until the result is semantically complete, readable, maintainable, and close to publication quality when the source is readable. Prioritize semantic structure, accurate math, and practical polish over pixel-perfect recreation.

Codex performs the conversion work directly with local tools, visual reasoning, and LaTeX editing. This skill does not provide or require a bundled converter, local OCR engine, or cloud OCR API. Use local PDF tools for metadata, page splitting, page rendering, digital text-layer extraction, asset extraction, and LaTeX compilation. Use bundled helper scripts only for repeatable rendering, artifact checks, and compile health checks.

## Reference Routing

- Read `references/pdf-analysis.md` before inspecting or transcribing the source PDF.
- Read `references/latex-rebuild.md` before creating or editing the LaTeX project.
- Read `references/book-production.md` when the PDF is a book, textbook, technical monograph, proceedings volume, thesis, dissertation, long academic manual, or contains book-specific structures such as preface, table of contents, list of figures/tables, appendices, bibliography, glossary, or index.
- Read `references/latex-refinement.md` before polishing generated LaTeX, fixing compile or layout issues, or comparing the rebuilt PDF against the source.
- Read `references/math-polish.md` when the document is math-heavy, the text layer has custom encoded symbols, or final source contains math placeholders such as `\pdfglyph` or `extracteddisplay`.
- Read `references/quality-review.md` before final delivery or a formal quality review, not for every routine compile.
- Read `references/goal-mode.md` before creating or continuing a goal-backed PDF-to-LaTeX conversion.
- Use `scripts/init_latex_project.sh`, `scripts/upgrade_latex_project.sh`, `scripts/render_pdf_pages.sh`, `scripts/extract_text_pages.sh`, `scripts/render_rebuilt_pages.sh`, `scripts/check_latex_artifacts.sh`, and `scripts/latex_healthcheck.sh` when they fit the local environment; they are helpers, not a replacement for semantic reconstruction. Use `assets/templates/` as the standard scaffold source when creating state, notes, manifest, inventory, IR, math, glyph, or goal tracking files. The helper scripts are intentionally conservative: scaffold only from PDF-looking sources, refuse unrelated non-empty targets, preserve existing project files, and refuse to replace rendered or extracted page evidence unless `--force` is explicit. Use page-selection flags such as `--pages 1,3,5-8` or `--from 10 --to 20` for large PDFs.

## Task Profiles

Choose the lightest profile that can satisfy the user request.

- **light**: use for small, mostly textual PDFs, narrow repairs, rough drafts, or simple refinement. Keep `main.tex`, `conversion-state.md`, and `conversion-notes.md`; use a concise outline in `conversion-notes.md` instead of standalone inventories or document IR unless they add review value.
- **standard**: use for ordinary papers, reports, or mixed PDFs. Maintain `page-manifest.md`, `object-inventory.md`, `style-profile.md`, `document-ir.md`, stable evidence paths, compile logs, and focused refinement passes.
- **book**: use for books, textbooks, theses, proceedings, monographs, long manuals, front/back matter, generated lists, appendices, bibliography, glossary, or index.
- **math-heavy**: use for documents with many formulas, damaged math extraction, encoded math layers, recurring glyph artifacts, or final source likely to contain math placeholders during drafting.
- **book-math**: use when both book-scale and math-heavy guidance apply.

Use these exact lowercase profile values when invoking helper scripts. Record the chosen profile, any later profile upgrade, and any simplifications in `conversion-notes.md`.

Profile file expectations:

```text
Profile      Required tracking files
light        main.tex, conversion-state.md, conversion-notes.md
standard     light files plus page-manifest.md, object-inventory.md, style-profile.md, document-ir.md
book         standard files plus frontmatter/ and backmatter/ when useful
math-heavy   standard files plus math-inventory.md and glyph-map.md
book-math    book files plus math-inventory.md and glyph-map.md
```

`goal-objective.md` is optional and belongs only to goal-backed work. If a project starts as `standard` and later needs a heavier profile, run `scripts/upgrade_latex_project.sh TARGET_DIR NEW_PROFILE`, or add the missing template files manually without overwriting existing work, then update `conversion-state.md` and `conversion-notes.md`.

## Delivery Levels

Choose the delivery level before major reconstruction and record it in `conversion-state.md` and `conversion-notes.md`.

- **Rough draft**: use only when the user asks for speed, a first pass, or a partial conversion. Compile when practical, record gaps, and do not claim quality review complete.
- **Clean semantic**: default for ordinary full conversions. Produce editable LaTeX, compile successfully, remove raw transcript artifacts, preserve major content, and complete the applicable minimum refinement checks.
- **Publication polish**: use when the user requests high fidelity, the document is book-scale or math-heavy, or the goal objective requires it. Complete the full book/math quality gates and reviewer checks before delivery.

## Initial Triage

Before creating a new scaffold, read `references/pdf-analysis.md` and do only enough pre-scaffold triage for the helper to receive the right profile, delivery level, and safe target path:

1. Confirm the source file is a PDF and the target directory is safe to use.
2. Check page count and metadata with `pdfinfo` when available.
3. For selectable PDFs, sample the text layer with page-bounded extraction such as `pdftotext -f 1 -l 1 -layout SOURCE_PDF -`.
4. For scanned, mixed, long, or visually complex PDFs, render only representative pages first when practical: page 1, an early body page, a middle page, a final page, and any obvious table/formula/reference pages. Use `scripts/render_pdf_pages.sh SOURCE_PDF TARGET_DIR DPI --pages LIST` after the target scaffold exists, or temporary render paths for pre-scaffold inspection.
5. Choose a provisional task profile from `light`, `standard`, `book`, `math-heavy`, or `book-math`, plus a delivery level.
6. For long, scanned, mixed, math-heavy, or book-scale PDFs, decide whether a full conversion needs explicit user confirmation, Goal mode approval, or a narrower first milestone before broad transcription.

After the scaffold exists, immediately write the durable triage and feasibility note into `conversion-notes.md` and update `conversion-state.md`. Include page count, estimated scanned or visually complex pages, planned batch size, first milestone, recommended delivery level, profile decision, and whether Goal mode was explicitly approved or state-file resumability will be used instead.

If the profile is uncertain, start with `standard` rather than guessing a heavier specialized profile. After deeper analysis, upgrade the project by adding missing tracking files, book directories, or math inventories from `assets/templates/`, then update `conversion-state.md` and `conversion-notes.md`.

## Default Output Contract

For a conversion task, create a `latex/` directory next to the source PDF unless the user gives another location. Do not silently overwrite an unrelated existing `latex/` directory. When the directory contains a resumable project, continue it; otherwise ask the user or choose a clearly named alternative after approval.

Maximum project layout:

```text
latex/
├── main.tex
├── chapters/
├── figures/
├── tables/
├── transcripts/
├── evidence/
│   ├── source-pages/
│   ├── rebuilt-pages/
│   ├── crops/
│   └── text-layer/
├── logs/
├── page-manifest.md
├── object-inventory.md
├── math-inventory.md
├── glyph-map.md
├── style-profile.md
├── document-ir.md
├── goal-objective.md      # only for goal-backed work
├── conversion-state.md
└── conversion-notes.md
```

This is profile-dependent, not a promise that every file always exists. Small documents may use fewer subdirectories, but explain the simplification in `conversion-notes.md`. Keep `evidence/source-pages/` for rendered source pages when visual transcription or later comparison is needed; use `evidence/rebuilt-pages/` for rendered output checks, `evidence/crops/` for figure or region crops, and `evidence/text-layer/` for page-bounded `pdftotext` evidence from digital PDFs. Keep page-level transcripts, object inventory, style profile, and document IR when they are useful for review, resume, or subagent integration. Keep `math-inventory.md` and `glyph-map.md` for math-heavy documents or any project with encoded glyph or display-math artifacts. For book-scale projects, use maintainable `frontmatter/`, `chapters/`, and `backmatter/` source boundaries when they help future editing.

When creating a new project, use `scripts/init_latex_project.sh SOURCE_PDF TARGET_DIR TASK_PROFILE DELIVERY_LEVEL` with one of the exact task profile values above and a delivery level such as `"clean semantic"`, or copy from `assets/templates/` when that avoids hand-written scaffold drift. If omitted, the helper records `clean semantic`. Do not overwrite existing user files; helper scripts must preserve existing files unless the user explicitly asks to regenerate them. If rendered source pages already exist, use `scripts/render_pdf_pages.sh SOURCE_PDF TARGET_DIR DPI --force` only after deciding that replacing previous page evidence is intentional.

Always maintain `conversion-state.md` as the resumable checkpoint file. Keep it concise and update it whenever a milestone completes or the next action changes. It should include:

```text
Source PDF:
Target directory:
Last updated:
Current phase:
Task profile:
Delivery level:
Completed checkpoints:
Last successful command:
Active files:
Next action:
Blockers or uncertainties:
```

Use `conversion-notes.md` for richer evidence, decisions, commands, and unresolved details; use `conversion-state.md` for fast restart.

## Goal-Backed Execution

Treat a complex full conversion request such as `$pdf-to-latex 把 "book.pdf" 转成latex` as likely to benefit from goal-backed execution because PDF-to-LaTeX conversion can be long-running and resumable. Before starting substantial work on long, scanned, mixed, math-heavy, or book-scale PDFs, read `references/goal-mode.md`. Create or continue a concrete goal only when goal tools are available, current runtime policy allows it, and the user explicitly asked for Goal mode or approved it after a short confirmation. Do not force Goal mode for short light-profile conversions, one-off repairs, compile fixes, or user-requested rough drafts.

If goal creation is allowed and approved, the goal must require using this skill, reading `conversion-state.md` first on every continuation, updating checkpoints after each milestone, compiling with XeLaTeX, completing minimum refinement and quality review, clearing blocking math extraction artifacts when present, and stopping only when the quality checks pass or a true blocker is documented.

Ask for the shortest confirmation possible before calling a goal tool, for example: `这个转换任务很长。我可以用 Goal 模式持续执行直到质量检查通过吗？回复 y/Y 确认。` If the user does not approve Goal mode, goal tools are unavailable, or policy forbids goal creation, continue with the same resumable workflow using `conversion-state.md` and `conversion-notes.md`. Do not silently downgrade a full conversion into a one-turn rough draft unless the user explicitly asks for a rough draft or no goal mode.

## Automatic Conversion And Refinement Workflow

1. Confirm the source PDF path and target output location. If the target exists, first inspect it for `conversion-state.md`, `conversion-notes.md`, `main.tex`, LaTeX logs, and compiled PDFs.
2. When a resumable project is found, continue from `conversion-state.md`'s `Next action`. If the state file is missing but project artifacts exist, infer the current phase from available files and logs, create `conversion-state.md`, and resume without overwriting work.
3. For a new target directory, read `references/pdf-analysis.md`, run the pre-scaffold Initial Triage above, then create the scaffold with `scripts/init_latex_project.sh SOURCE_PDF TARGET_DIR TASK_PROFILE DELIVERY_LEVEL` or the matching files in `assets/templates/`. Immediately write durable triage notes and update `conversion-state.md`.
4. Continue the PDF analysis from `references/pdf-analysis.md`: inspect the PDF type, page count, text layer, images, tables, formulas, references, book-scale structures, and any scanned pages. Classify pages or regions as digital, scanned, mixed, encoded-math, or damaged-text, confirm or upgrade the task profile, then update the state file after analysis. If the PDF is book-scale, also read `references/book-production.md`.
5. Split or render the source into stable page-level evidence under `evidence/source-pages/`. Prefer per-page images for Codex visual transcription; keep single-page PDFs only when they help asset extraction or page-specific inspection. Use zero-padded page names such as `page-001.png`. For large PDFs, render representative pages first, confirm the profile, then render needed batches with `scripts/render_pdf_pages.sh SOURCE_PDF TARGET_DIR DPI --pages 1,3,5-8` or `--from START --to END`.
6. Create `page-manifest.md` with the page or region route map when the selected profile needs page-level tracking. For digital pages only, store optional text-layer evidence under `evidence/text-layer/` with page-bounded names such as `page-001.txt`; prefer `scripts/extract_text_pages.sh SOURCE_PDF TARGET_DIR --pages LIST` when it fits. Never use local OCR engines.
7. Use Codex visual recognition to transcribe each page or page batch into semantic LaTeX fragments under `transcripts/` or equivalent notes. For long documents, default to small resumable batches: 5-10 visually transcribed pages per batch for scanned or complex pages, and 20-50 pages per batch for mostly digital prose after text-layer evidence is available. Update `page-manifest.md` and `conversion-state.md` after each batch. Use subagents for independent page batches only when the current environment and user instructions permit parallel agent work, and keep subagents on bounded transcript or review outputs rather than shared project-state edits.
8. Build `object-inventory.md`, `style-profile.md`, and `document-ir.md` before writing final LaTeX when the selected profile needs them. For light-profile tasks, a concise outline and object list inside `conversion-notes.md` may replace standalone files; record that simplification before drafting. Track document type, section hierarchy, body blocks, figures, tables, formulas, citations, appendices, cross-page merges, style decisions, and unresolved objects. For book-scale PDFs, track front matter, main matter, back matter, table of contents, lists of figures/tables, bibliography, index/glossary when present, and cross-reference policy using `references/book-production.md`. For math-heavy or damaged-text PDFs, also create `math-inventory.md` and `glyph-map.md` using `references/math-polish.md`. Record the IR or light-outline checkpoint and next action.
9. Populate the LaTeX project with XeLaTeX as the default engine using `references/latex-rebuild.md`. Generate final chapters from the document IR rather than directly stitching page fragments, and update the state file with created files and active gaps.
10. Compile the generated project and inspect errors, warnings, rendered pages, extracted text, `conversion-state.md`, and `conversion-notes.md`. Store useful logs under `logs/` and rendered output pages under `evidence/rebuilt-pages/`; prefer `scripts/render_rebuilt_pages.sh TARGET_DIR main.pdf DPI` when it fits. Record compile success or the first hard failure.
11. Run the multi-pass polish loop in `references/latex-refinement.md`: fix compile issues, remove page-transcript artifacts, improve document structure, convert rough text into idiomatic LaTeX objects, run book-production passes when applicable, run math publication polish when needed, tune typography, run reviewer checks, and visually compare rendered output. Update the state file after each focused pass.
12. Repeat review and refinement until the rebuilt PDF satisfies the selected delivery level or a true blocker is documented. Do not deliver the first compiling PDF as final unless the user explicitly requested only a rough draft. Do not mark clean semantic or publication polish complete while final source still contains broad math artifacts such as `\pdfglyph{...}` or `extracteddisplay`.
13. Deliver the project path, compiled PDF path, verification performed, refinements made, and remaining uncertainties.

If the user provides an existing generated LaTeX project, skip initial reconstruction and start with the refinement/resume path: read or create `conversion-state.md`, inspect `conversion-notes.md`, compile the current project, infer or record the task profile and delivery level, add missing notes or inventories only when needed, then run steps 10-13. Treat refinement as part of the default job, not as a separate optional follow-up.

## Subagent Batch Contract

Use subagents only for bounded page transcription, math review, or reviewer passes when the current environment and user instructions permit it. Give each subagent only the relevant page images, optional text-layer excerpts, neighboring context, and the required transcript or finding format. Subagents should return transcripts, object notes, math findings, or review findings; the main agent owns merges, edits to `main.tex` and chapter files, updates to `conversion-state.md`, `conversion-notes.md`, `document-ir.md`, `glyph-map.md`, compilation, and final quality decisions.

## Codex Visual Transcription Workflow

For scanned, mixed, damaged-text, or visually complex PDFs, follow this normal path:

1. Render pages at practical analysis resolution and keep those images under `evidence/source-pages/` as page-level evidence.
2. Give Codex the rendered page image, optional neighboring-page context, and optional digital text-layer excerpt when the page is digital.
3. Transcribe each page into structured semantic LaTeX fragments, especially headings, paragraphs, formulas, tables, captions, footnotes, and references.
4. Mark page starts, page ends, cross-page continuations, figure/table needs, and uncertain symbols or text.
5. Build an object inventory, style profile, and document IR from the page transcripts and visual page review.
6. Write LaTeX from the document IR as editable text, math, semantic tables, citations, and cropped real figures only.
7. Compile and refine the semantic LaTeX. If a region is unreadable, leave a concise placeholder and document the uncertainty instead of embedding the scanned page.

Do not use `tesseract`, `ocrmypdf`, local OCR engines, or cloud OCR APIs. Do not use full-page scanned screenshots as a compile shortcut. They are expensive, uneditable, and outside the default purpose of this skill.

## Resume Behavior

Before doing substantial work, read `conversion-state.md` when it exists. Trust explicit user instructions over the state file, but otherwise use the state file to avoid repeating completed analysis, transcription, extraction, compile fixes, or review passes.

If `conversion-state.md` and project artifacts disagree, verify the filesystem and logs, then update the state file to match reality before continuing. Preserve user edits in the target project; when unsure whether a file is generated or user-authored, inspect it and record the decision.

Write a state update before ending a long turn, after each successful compile, after each failed compile diagnosis, and after each meaningful refinement pass. A future Codex agent should be able to resume by reading only `conversion-state.md`, then loading the referenced notes, logs, and files.

## Conversion Rules

- Prefer semantic rebuilding over visual tracing. Preserve meaning, reading order, headings, formulas, tables, figures, captions, references, and clear layout.
- For book-scale PDFs, preserve visible front matter, main matter, back matter, table of contents/list structure, appendices, bibliography, index/glossary, and cross-references semantically when present; do not invent absent book apparatus.
- For every scanned or visually complex page, use Codex visual recognition from rendered page images as the transcription source. Do not use local OCR.
- For digital PDFs, `pdftotext` may be used only as optional text-layer evidence. Codex visual review remains responsible for reading order, formulas, tables, captions, footnotes, and extraction correction.
- For scanned PDFs, rebuild normal LaTeX content: visually transcribe text into paragraphs and sections, convert formulas into math, rebuild legible tables semantically, and include only genuine figures or diagrams as cropped figure assets.
- For math-heavy or encoded PDFs, treat `\pdfglyph`, `extracteddisplay`, raw encoded math, and placeholder math comments as blocking draft artifacts in final source unless the user explicitly approves a rough draft. Use `math-inventory.md`, `glyph-map.md`, rendered source pages, and Codex visual recognition to resolve them.
- Use public web lookup only when it helps identify public metadata, citations, public versions, standard formulas, or source context. Label web-sourced additions separately from PDF-derived content.
- Use XeLaTeX by default, especially for Unicode, multilingual text, and CJK documents.
- Prefer stable project-local evidence paths over `/tmp` for anything needed after the current turn.
- Use helper scripts and bundled templates when they reduce repeatable command errors or scaffold drift, but do not treat them as a conversion engine or proof of quality.
- Keep LaTeX maintainable: use packages intentionally, split long content into chapters or sections, and avoid brittle absolute positioning unless the user explicitly requests visual recreation.
- Make small, reviewable refinement edits. Compile after each focused batch before moving to the next class of issues.
- Continue through content uncertainty when a reasonable approximation is possible, but clearly mark approximations, missing details, and inferred material.
- When scanned content cannot be reliably read, insert a concise semantic placeholder or source comment and document the gap in `conversion-notes.md`; do not use full-page screenshots to make the PDF compile.

## Stop And Ask

Ask the user before proceeding when:

- The source PDF path is missing or ambiguous.
- The target `latex/` directory already exists, has no recoverable state or recognizable project artifacts, and proceeding may overwrite user work.
- A required system tool for the requested verification is missing and cannot be used.
- Formula symbols or math regions remain unreadable after visual review and available context, and leaving them unresolved would block near-publication delivery.
- The user asks for a bundled converter, local OCR dependency, cloud OCR dependency, or generic PDF editing behavior outside LaTeX reconstruction.
- A newer user instruction conflicts with this skill's output contract.
