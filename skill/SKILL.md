---
name: pdf-to-latex
description: "Use when Codex needs to convert a user-provided PDF into an editable LaTeX or XeLaTeX project, rebuild or refine a PDF-derived LaTeX project, compile the result, and run semantic quality review with mandatory Goal-mode planning when supported. Handles digital, scanned, mixed, math-heavy, book-scale, thesis, and technical PDFs. Not for generic PDF editing, signing, compression, page rearrangement, form filling, or extraction-only tasks unless the goal is LaTeX reconstruction."
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
- Read `references/reviewer-gates.md` before running midpoint or final reviewer gates for `publication polish`.
- Read `references/quality-review.md` before final delivery or a formal quality review, not for every routine compile.
- Read `references/goal-mode.md` during initial triage for every conversion, reconstruction, broad refinement, or quality-review request so Goal-mode planning is resolved before substantial work.
- Use `scripts/init_latex_project.sh`, `scripts/upgrade_latex_project.sh`, `scripts/render_pdf_pages.sh`, `scripts/extract_text_pages.sh`, `scripts/render_rebuilt_pages.sh`, `scripts/check_latex_artifacts.sh`, `scripts/check_workflow_gates.sh`, `scripts/latex_healthcheck.sh`, and `scripts/publication_gate.sh` when they fit the local environment; they are helpers, not a replacement for semantic reconstruction. Use `assets/templates/` as the standard scaffold source when creating state, notes, manifest, inventory, IR, math, glyph, or goal tracking files. The helper scripts are intentionally conservative: scaffold only from PDF-looking sources, refuse unrelated non-empty targets, preserve existing project files, and refuse to replace rendered or extracted page evidence unless `--force` is explicit. Use page-selection flags such as `--pages 1,3,5-8` or `--from 10 --to 20` for large PDFs.

## Canonical Workflow Contract

Treat this file as the source of truth for task profile names, delivery levels, mandatory Goal-mode planning, default output contract, required state fields, and stop-and-ask rules. Reference files may add local procedure, examples, and quality gates, but they should not redefine the profile matrix, Goal-mode contract, or delivery-level contract. When a scaffold template and prose differ, prefer the bundled template and update the prose to match.

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

`goal-objective.md` is optional and belongs only to goal-backed work; record the Goal-mode decision in `conversion-state.md` and `conversion-notes.md` even when this optional file is omitted. If a project starts as `standard` and later needs a heavier profile, run `scripts/upgrade_latex_project.sh TARGET_DIR NEW_PROFILE`, or add the missing template files manually without overwriting existing work, then update `conversion-state.md` and `conversion-notes.md`.

## Delivery Levels

Choose the delivery level before major reconstruction and record it in `conversion-state.md` and `conversion-notes.md`. For `publication polish`, also record the acceptance contract: semantic fidelity target, typography/layout target, allowed approximations, blocker policy, and whether exact pagination is a goal.

- **Rough draft**: use only when the user asks for speed, a first pass, or a partial conversion. Compile when practical, record gaps, and do not claim quality review complete.
- **Clean semantic**: default for ordinary full conversions. Produce editable LaTeX, compile successfully, remove raw transcript artifacts, preserve major content, and complete the applicable minimum refinement checks.
- **Publication polish**: use when the user requests publication-grade, high fidelity, book-scale, math-heavy, camera-ready-like, or goal-backed quality. Treat unresolved readable content, broad object gaps, unresolved references, unreviewed math artifacts, failed clean-room builds, and undocumented approximations as blocking defects unless the user explicitly accepts them.

## Publication Pipeline Gates

For `publication polish`, treat these gates as required unless a true blocker is documented:

1. **Goal-mode planning gate**: before scaffolding or broad work, classify the request as `goal-required`, `goal-skipped`, or `goal-unavailable-fallback`; create or continue the Goal when required and available, or record the fallback/blocker.
2. **Delivery contract gate**: before broad work, record the selected delivery level, fidelity target, non-goals, allowed approximation policy, unresolved-content policy, exact-pagination policy, and expected final verification in `conversion-notes.md`.
3. **Production spec gate**: before broad transcription or final drafting, record the intended document class, source page size, target paper size, page geometry, font and language plan, sectioning depth, figure/table/math strategy, citation and bibliography strategy, book/index/glossary strategy when applicable, non-goals such as pixel-perfect tracing, and toolchain assumptions in `style-profile.md` and `conversion-notes.md`.
4. **Evidence and route gate**: classify pages or regions as digital, scanned, mixed, encoded-math, damaged-text, or visual-complex, then record a route map in `page-manifest.md` before broad work. Digital pages may use text-layer evidence plus visual correction; scanned and damaged regions require visual transcription.
5. **Inventory seed gate**: seed `object-inventory.md`, `style-profile.md`, `document-ir.md`, and math/book tracking files before large-scale reconstruction, then finalize them as batches complete.
6. **Source completeness audit gate**: before large-scale reconstruction, reconcile page routes with `object-inventory.md` and `document-ir.md`. Every source page or meaningful region should be marked `pending`, `in-progress`, `rebuilt`, `reviewed`, `blocked`, or `omitted-with-reason`; every major figure, table, formula, citation, appendix, front/back-matter item, index/glossary item, and unresolved visual region should have an owner/status.
7. **Skeleton compile gate**: before filling most final content, create the production preamble, document class, package choices, macros, chapter inputs, bibliography/index/glossary hooks when used, and compile the skeleton successfully.
8. **Asset discovery gate**: before drafting large final chapters, locate figure/table/diagram/bibliography/math assets, decide which objects are cropped, recreated, semantic, or blocked, and record statuses in `object-inventory.md`.
9. **Batch compile gate**: compile after each chapter, major section, or high-risk object batch before starting the next batch.
10. **Midpoint reviewer gate**: after route maps, inventories, production spec, asset discovery, and skeleton compile are ready, review the plan for missing content, weak object strategy, class/package mistakes, and likely book/math blockers before most final drafting.
11. **Final reviewer gate**: perform independent reviewer passes for structure/content, math/objects, and build/layout after polishing. Use subagents for bounded findings when permitted; otherwise perform the passes separately and record results.
12. **Workflow gate check**: before delivery, run `scripts/check_workflow_gates.sh TARGET_DIR` when available so state-file checkpoints, acceptance gate values, and obvious unfinished statuses are checked deterministically.
13. **Clean-room build gate**: before delivery, rebuild from a clean project copy or clean working tree state so hidden auxiliary files, absolute paths, stale generated files, or missing assets are caught. Prefer `scripts/publication_gate.sh TARGET_DIR main.tex --strict-findings` when available, then record the result.

## Initial Triage

Before creating a new scaffold, read `references/pdf-analysis.md` and do only enough pre-scaffold triage for the helper to receive the right profile, delivery level, and safe target path:

1. Confirm the source file is a PDF and the target directory is safe to use.
2. Check page count and metadata with `pdfinfo` when available.
3. For selectable PDFs, sample the text layer with page-bounded extraction such as `pdftotext -f 1 -l 1 -layout SOURCE_PDF -`.
4. For scanned, mixed, long, or visually complex PDFs, render only representative pages first when practical: page 1, an early body page, a middle page, a final page, and any obvious table/formula/reference pages. Use `scripts/render_pdf_pages.sh SOURCE_PDF TARGET_DIR DPI --pages LIST` after the target scaffold exists, or temporary render paths for pre-scaffold inspection.
5. Choose a provisional task profile from `light`, `standard`, `book`, `math-heavy`, or `book-math`, plus a delivery level.
6. Run Mandatory Goal Mode Planning from this file. For `goal-required` work, create or continue the Goal before broad transcription when goal tools are available and policy allows it; otherwise record `goal-unavailable-fallback` or stop for required user approval.

After the scaffold exists, immediately write the durable triage and feasibility note into `conversion-notes.md` and update `conversion-state.md`. Include page count, estimated scanned or visually complex pages, planned batch size, first milestone, recommended delivery level, profile decision, initial production-spec assumptions for publication polish, and the Goal-mode decision, active Goal status, or fallback reason.

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

This is profile-dependent, not a promise that every file always exists. The scaffold helper keeps `light` projects minimal with core files and `logs/`, and creates heavier working directories only for `standard`, `book`, `math-heavy`, or `book-math` profiles. Small documents may use fewer subdirectories, but explain the simplification in `conversion-notes.md`. Keep `evidence/source-pages/` for rendered source pages when visual transcription or later comparison is needed; use `evidence/rebuilt-pages/` for rendered output checks, `evidence/crops/` for figure or region crops, and `evidence/text-layer/` for page-bounded `pdftotext` evidence from digital PDFs. Keep page-level transcripts, object inventory, style profile, and document IR when they are useful for review, resume, or subagent integration. Keep `math-inventory.md` and `glyph-map.md` for math-heavy documents or any project with encoded glyph or display-math artifacts. For book-scale projects, use maintainable `frontmatter/`, `chapters/`, and `backmatter/` source boundaries when they help future editing.

When creating a new project, use `scripts/init_latex_project.sh SOURCE_PDF TARGET_DIR TASK_PROFILE DELIVERY_LEVEL` with one of the exact task profile values above and a delivery level such as `"clean semantic"`, or copy from `assets/templates/` when that avoids hand-written scaffold drift. If omitted, the helper records `clean semantic`. Do not overwrite existing user files; helper scripts must preserve existing files unless the user explicitly asks to regenerate them. If rendered source pages already exist, use `scripts/render_pdf_pages.sh SOURCE_PDF TARGET_DIR DPI --force` only after deciding that replacing previous page evidence is intentional.

Always maintain `conversion-state.md` as the resumable checkpoint file. Keep it concise and update it whenever a milestone completes or the next action changes. It should include:

```text
Source PDF:
Target directory:
Last updated:
Current phase:
Task profile:
Delivery level:
Goal mode decision:
Goal status:
Completed checkpoints:
Last successful command:
Active files:
Next action:
Blockers or uncertainties:
```

Use `conversion-notes.md` for richer evidence, decisions, commands, and unresolved details; use `conversion-state.md` for fast restart.

## Mandatory Goal Mode Planning

Before scaffolding a new conversion, resuming broad reconstruction, or starting major refinement or quality review, read `references/goal-mode.md` and classify the request in `conversion-state.md` and `conversion-notes.md` as one of:

- `goal-required`: use for any full PDF-to-LaTeX conversion or rebuild; any existing PDF-derived LaTeX project needing broad refinement or quality review; any `publication polish` task; any long, scanned, mixed, math-heavy, encoded, book-scale, or multi-batch task. This includes light-profile full conversions when the user expects a completed LaTeX project rather than a one-shot rough draft.
- `goal-skipped`: use only for explaining this skill, initial triage with no reconstruction, reviewing a snippet, fixing one localized compile or layout issue, or a user-requested rough draft, one-shot partial pass, or narrow repair that can be completed in the current turn. Record the reason.
- `goal-unavailable-fallback`: use when the task is `goal-required` but goal tools are unavailable or runtime policy forbids goal creation. Continue with the same resumable workflow using `conversion-state.md` and `conversion-notes.md`, record the limitation, and do not lower the delivery level merely because Goal mode is unavailable.

When the decision is `goal-required` and goal tools are available, create or continue a concrete Goal after the source PDF and target directory are known and before major analysis, scaffolding, broad transcription, reconstruction, or refinement. If the current runtime requires explicit user approval and the user has not already requested Goal mode, ask for the shortest yes/no confirmation and stop before broad work until it is approved. If the user declines Goal mode for a `goal-required` full conversion, do not proceed as a normal full conversion; ask whether to reduce scope to rough draft, triage, or a narrow repair, or record a blocker.

The Goal must require using this skill, reading `conversion-state.md` first on every continuation, updating checkpoints after each milestone, compiling with XeLaTeX, completing minimum refinement and quality review, clearing blocking math extraction artifacts when present, and stopping only when the quality checks pass or a true blocker is documented.

## Automatic Conversion And Refinement Workflow

1. Confirm the source PDF path and target output location, then run Mandatory Goal Mode Planning. If the target exists, first inspect it for `conversion-state.md`, `conversion-notes.md`, `main.tex`, LaTeX logs, and compiled PDFs.
2. When a resumable project is found, continue from `conversion-state.md`'s `Next action`. If the state file is missing but project artifacts exist, infer the current phase from available files and logs, create `conversion-state.md`, and resume without overwriting work.
3. For a new target directory, read `references/pdf-analysis.md`, run the pre-scaffold Initial Triage above, then create the scaffold with `scripts/init_latex_project.sh SOURCE_PDF TARGET_DIR TASK_PROFILE DELIVERY_LEVEL` or the matching files in `assets/templates/`. Immediately write durable triage notes and update `conversion-state.md`.
4. Run the delivery contract gate for `publication polish`, or a lighter delivery note for other levels. Record fidelity target, non-goals, approximation policy, unresolved-content policy, exact-pagination policy, and expected final verification.
5. Run the production spec gate for `publication polish`, or a lighter style decision pass for other delivery levels. Record class, source page size, target paper size, geometry, fonts, source structure, object strategy, bibliography/index/glossary strategy, toolchain assumptions, and non-goals before broad reconstruction.
6. Continue PDF analysis from `references/pdf-analysis.md`: inspect PDF type, page count, text layer, images, tables, formulas, references, book-scale structures, and scanned pages. Classify pages or regions as digital, scanned, mixed, encoded-math, damaged-text, or visual-complex, confirm or upgrade the task profile, then update the state file after analysis. If the PDF is book-scale, also read `references/book-production.md`.
7. Split or render source evidence under `evidence/source-pages/` only where visual transcription or later comparison is needed. Render representative pages first for large PDFs, then render needed batches with `scripts/render_pdf_pages.sh SOURCE_PDF TARGET_DIR DPI --pages 1,3,5-8` or `--from START --to END`.
8. Create `page-manifest.md` with a page or region route map before broad work when the selected profile needs tracking. For digital pages, store page-bounded text-layer evidence under `evidence/text-layer/` when useful; prefer `scripts/extract_text_pages.sh SOURCE_PDF TARGET_DIR --pages LIST`. Never use local OCR engines.
9. Seed `object-inventory.md`, `style-profile.md`, and `document-ir.md` before large-scale reconstruction when the selected profile needs them. For book-scale PDFs, seed front matter, main matter, back matter, generated lists, bibliography, index/glossary, and cross-reference policy using `references/book-production.md`. For math-heavy or damaged-text PDFs, seed `math-inventory.md` and `glyph-map.md` using `references/math-polish.md`.
10. Run the source completeness audit gate before broad drafting: reconcile page routes, object inventory, style profile, document IR, and math/book tracking. Mark each page, region, and major object with a concrete status and document omissions or blockers.
11. Run the skeleton compile gate: create the production preamble, document class, packages, macros, file structure, and bibliography/index/glossary hooks when used; compile a minimal skeleton with XeLaTeX; record the command, output, warnings, and any toolchain fallbacks.
12. Run asset discovery before final drafting: locate or plan genuine figures, tables, diagrams, bibliography data, formulas, crops, and recreated objects; record whether each item will be semantic, cropped, recreated, blocked, or omitted with reason.
13. Run the midpoint reviewer gate for `publication polish` before most final content is drafted. Review the route map, completeness audit, production spec, skeleton compile, asset discovery, and likely book/math blockers; fix plan-level gaps before proceeding.
14. Reconstruct content by route rather than blindly transcribing every page. For mostly digital prose, use page-bounded text-layer evidence plus visual correction and object review. For scanned, mixed, damaged-text, or visually complex regions, use Codex visual recognition into bounded transcripts or notes. For encoded math, maintain `math-inventory.md` and `glyph-map.md` while resolving recurring symbols. Update the manifest and state after each batch.
15. Populate the LaTeX project from `document-ir.md` or a documented light-profile outline using `references/latex-rebuild.md`. Do not directly stitch page fragments into final chapters except for very small documents where the notes justify it.
16. Compile after each chapter, major section, or high-risk object batch. Inspect errors, warnings, rendered pages, extracted text, `conversion-state.md`, and `conversion-notes.md`; store useful logs under `logs/` and rebuilt render evidence under `evidence/rebuilt-pages/`.
17. Run focused polish passes from `references/latex-refinement.md`: compile fixes, transcript cleanup, structure, LaTeX idiom/object polish, math publication polish, book production, typography, reviewer checks, visual comparison, and final cleanup. Update the state file after each focused pass.
18. Run final reviewer gates required for `publication polish` using `references/reviewer-gates.md`: structure/content review, math/object review, and build/layout review. Use subagents for bounded findings when permitted; otherwise perform separate passes and record results in `conversion-notes.md`.
19. Run the final quality review from `references/quality-review.md`, including the clean-room build gate and workflow gate check. Prefer `scripts/publication_gate.sh TARGET_DIR main.tex --strict-findings` and `scripts/check_workflow_gates.sh TARGET_DIR` when available for deterministic compile, artifact, render, clean rebuild, and state-file gate checks.
20. Repeat review and refinement until the rebuilt PDF satisfies the selected delivery level or a true blocker is documented. Do not deliver the first compiling PDF as final unless the user explicitly requested only a rough draft. Do not mark clean semantic or publication polish complete while final source still contains broad math artifacts such as `\pdfglyph{...}` or `extracteddisplay`.
21. Deliver the project path, compiled PDF path, verification performed, refinements made, clean-room build status, and remaining uncertainties.

If the user provides an existing generated LaTeX project, skip initial reconstruction and start with the refinement/resume path: read or create `conversion-state.md`, inspect `conversion-notes.md`, infer or record the task profile and delivery level, add or repair the delivery contract, production spec, completeness audit, and missing inventories only when needed, compile the current project, then run the applicable batch compile, polish, reviewer, quality-review, and clean-room build gates from steps 16-21. Treat refinement as part of the default job, not as a separate optional follow-up.

## Subagent Batch Contract

Use subagents only for bounded page transcription, math review, or reviewer passes when the current environment and user instructions permit it. Give each subagent only the relevant page images, optional text-layer excerpts, neighboring context, and the required transcript or finding format. Subagents should return transcripts, object notes, math findings, or review findings; the main agent owns merges, edits to `main.tex` and chapter files, updates to `conversion-state.md`, `conversion-notes.md`, `document-ir.md`, `glyph-map.md`, compilation, and final quality decisions.

## Codex Visual Transcription Workflow

For scanned, mixed, damaged-text, or visually complex PDFs, follow this normal path:

1. Render pages at practical analysis resolution and keep those images under `evidence/source-pages/` as page-level evidence.
2. Give Codex the rendered page image, optional neighboring-page context, and optional digital text-layer excerpt when the page is digital.
3. Transcribe each page into structured semantic LaTeX fragments, especially headings, paragraphs, formulas, tables, captions, footnotes, and references.
4. Mark page starts, page ends, cross-page continuations, figure/table needs, and uncertain symbols or text.
5. Seed or update an object inventory, style profile, and document IR from the page transcripts and visual page review.
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
- Prefer matching the source PDF paper size in generated LaTeX. Record the original page size or mixed-size pattern during analysis, choose a target paper size that matches the dominant or representative source size when practical, and document exceptions such as mixed page sizes, unreadable metadata, or user-requested reflow.
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
- Goal mode is required, the runtime requires explicit approval, and the user declines or has not answered.
- Formula symbols or math regions remain unreadable after visual review and available context, and leaving them unresolved would block near-publication delivery.
- The user asks for a bundled converter, local OCR dependency, cloud OCR dependency, or generic PDF editing behavior outside LaTeX reconstruction.
- A newer user instruction conflicts with this skill's output contract.
