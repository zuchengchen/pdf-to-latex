# Quality Review Reference

Use this reference before delivering a rebuilt LaTeX project. The quality bar follows the recorded delivery level: rough draft, clean semantic, or publication polish. The normal target is semantic completeness and readability, with near-publication math quality when formulas are visible, readable, and the selected profile requires it; the target is not pixel-level matching.

## Contents

- Required Checks
- Minimum Done By Profile
- Publication-Polish Acceptance Gates
- Compile
- Text Checks
- Math Artifact Checks
- Visual Review
- Clean-Room Build
- Workflow Gate Check
- Downgrade Or Blocker Policy
- Notes Review
- Refinement Acceptance
- Delivery Checklist
- Completion Standard

## Required Checks

1. Compile the project with XeLaTeX or an equivalent XeLaTeX-based command.
2. Inspect compile logs for missing files, undefined commands, unresolved references, overfull boxes, and font problems.
3. Extract text from the compiled PDF when possible and compare it with key source content, including page-bounded files under `evidence/text-layer/` when digital text-layer evidence was used.
4. Render or open the compiled PDF and check readability, page flow, figures, tables, formulas, and references. Store durable render artifacts under `evidence/rebuilt-pages/` when they help review or resume.
5. Compare final chapters against the delivery contract, source completeness audit, `document-ir.md`, `object-inventory.md`, and `style-profile.md` when present. For light-profile tasks, compare against the recorded concise outline or simplification notes.
6. For publication polish, confirm the Goal-mode planning, delivery contract, production spec, source completeness audit, asset discovery, skeleton compile, batch compile, midpoint reviewer, final reviewer, visual comparison, and clean-room build gates are passed or blocked with concrete user-facing reasons.
7. For book-scale projects, apply `references/book-production.md` quality gates for front matter, table of contents, lists of figures/tables, chapters, appendices, bibliography, index/glossary when present, and cross-references.
8. For math-heavy, encoded, or formula-damaged projects, run math artifact scans on final source and reconcile `math-inventory.md` and `glyph-map.md`.
9. Complete the quality rubric from `latex-refinement.md`.
10. For publication polish, complete structure/content, math/object, and build/layout final reviewer gates using `references/reviewer-gates.md`.
11. For publication polish, run a clean-room build gate from a clean project copy or clean working tree state. Prefer `scripts/publication_gate.sh PROJECT_DIR main.tex --strict-findings` when available.
12. For publication polish, run `scripts/check_workflow_gates.sh PROJECT_DIR` when available to verify state-file and acceptance-gate completion.
13. Update `conversion-notes.md` with verification results, rubric status, clean-room build result, workflow gate result, and remaining uncertainties.
14. Update `conversion-state.md` with the latest successful command, completed quality checkpoints, and any remaining next action.
15. Confirm the minimum refinement passes from `latex-refinement.md` were completed or explicitly marked not applicable.
16. Confirm the workflow did not use local OCR engines such as `tesseract` or `ocrmypdf`; `pdftotext` is acceptable only for digital text-layer evidence or output verification.
17. For scanned PDFs, confirm the rebuilt output is semantic LaTeX content rather than full-page screenshot embedding, unless the user explicitly requested visual replication.

For normal PDF-to-LaTeX work, perform the minimum refinement passes after the first successful compile. The first compiling PDF is a checkpoint, not the default final deliverable. For an explicit rough draft, record skipped clean-semantic checks and do not mark quality review complete.

## Minimum Done By Profile

Use the selected profile to avoid both under-reviewing complex work and overloading simple work. Use `SKILL.md` for the canonical profile file requirements; this table only defines the review floor:

```text
light        compiles when practical, main content is editable, notes record skipped heavy checks and unresolved gaps
standard     light checks plus page route or outline, object/style/IR reconciliation, compile, representative text/visual review
book         standard checks plus book front/main/back matter, generated-list strategy, numbering, cross-reference and back-matter review
math-heavy   standard checks plus math-inventory/glyph-map reconciliation, clean artifact scan, representative formula visual review
book-math    book and math-heavy checks together
```

For clean semantic delivery, the matching row is the minimum bar. For publication polish, also complete all applicable reviewer, visual comparison, book, math, clean-room build, and final cleanup gates below. For rough draft delivery, explicitly list which row items remain unfinished.

## Publication-Polish Acceptance Gates

Treat these gates as required for `publication polish` unless a true blocker is documented and surfaced to the user:

```text
Goal mode planning: pass | blocked
Delivery contract: pass | blocked
Production spec: pass | blocked
Source completeness audit: pass | blocked
Skeleton compile: pass | blocked
Asset discovery: pass | blocked
Batch compile history: pass | blocked
Midpoint reviewer: pass | blocked
Final structure/content reviewer: pass | blocked
Final math/object reviewer: pass | blocked | not applicable
Final build/layout reviewer: pass | blocked
Visual comparison: pass | blocked
Artifact scan: pass | blocked | not applicable
Clean-room build: pass | blocked
Final notes/state: pass | blocked
```

Use `not applicable` only when the source lacks that category, for example no math-heavy content or no book-specific apparatus. Do not use `not applicable` for unreadable or skipped content that the source visibly contains; mark it `blocked` or `omitted-with-reason` according to the delivery contract.

Quantified floor:

- Latest XeLaTeX build succeeds and produces the expected PDF.
- Goal-mode planning is recorded, and `goal-required` work used an active Goal when available or recorded a concrete fallback/blocker.
- `scripts/check_latex_artifacts.sh .` returns clean when math artifacts or placeholders were possible.
- `scripts/check_workflow_gates.sh .` returns clean for publication polish unless `--allow-blocked` is intentionally used for a documented blocked delivery.
- Final source has no broad `pending`, `in-progress`, or unowned page/object statuses for content required by the delivery contract.
- LaTeX logs have no unresolved references, citations, missing files, undefined commands, or rerun warnings that affect delivered content.
- Representative rendered pages are nonblank and readable; high-risk pages from the source completeness audit are included in visual review.
- Publication-polish clean-room build succeeds, or the final answer names a true blocker and does not claim publication polish complete.

## Compile

Prefer `latexmk` when available:

```bash
latexmk -xelatex -interaction=nonstopmode -halt-on-error main.tex
```

Fallback:

```bash
xelatex -interaction=nonstopmode -halt-on-error main.tex
xelatex -interaction=nonstopmode -halt-on-error main.tex
```

Run from inside the `latex/` directory unless paths are configured otherwise.

If the skill helper script is available and fits the project layout, it may be used as a wrapper:

```bash
path/to/pdf-to-latex/scripts/latex_healthcheck.sh . main.tex
```

Use the actual installed skill path.

If compilation fails, fix LaTeX source instead of hiding errors. Common fixes:

- Escape special characters.
- Add missing packages intentionally.
- Correct image paths and extensions.
- Replace unavailable fonts with portable defaults.
- Simplify unsupported bibliography tooling.
- Comment uncertain fragments only when necessary and record the issue.

## Text Checks

Use text extraction when available:

```bash
pdftotext rebuilt.pdf -
```

Confirm representative source content appears in the rebuilt PDF:

- Title and major headings.
- Book front matter, table of contents, lists of figures/tables, chapters, appendices, bibliography, index, and glossary when present.
- Key paragraphs or terms.
- Table headers and important cells.
- Formula identifiers or surrounding explanatory text.
- Figure captions.
- Bibliography entries or citation labels.
- Representative objects from `object-inventory.md`.

Do not require exact line breaks, pagination, or spacing.

## Math Artifact Checks

For math-heavy documents or any project that previously contained encoded math artifacts, scan final included source files before delivery:

```bash
rg -n '\\pdfglyph|extracteddisplay|TODO math|unresolved glyph|raw glyph|MATH_PLACEHOLDER' main.tex chapters/ tables/ 2>/dev/null
```

The final source scan should return no matches unless the user explicitly approved a rough draft or a documented unresolved item. Broad residual counts such as hundreds of `\pdfglyph` markers or placeholder display blocks are blocking defects, even when the project compiles.

Also confirm:

- `math-inventory.md` exists when formulas are numerous or damaged.
- `glyph-map.md` records recurring glyph decisions and confidence when encoded glyphs were present.
- Every major display equation in the inventory is rebuilt, compiled, and visually reviewed, or is listed as blocked with a concrete user-facing question.
- Placeholder display wrappers have been converted to standard math environments.
- Equation numbers, labels, and references remain consistent where visible.

When available, use the bundled helper for the final artifact gate. It scans project LaTeX and bibliography source while excluding transcript, evidence, and log directories:

```bash
path/to/pdf-to-latex/scripts/check_latex_artifacts.sh .
```

## Visual Review

Render pages or inspect the PDF directly:

```bash
mkdir -p evidence/rebuilt-pages
pdftoppm -png -r 140 rebuilt.pdf evidence/rebuilt-pages/page
path/to/pdf-to-latex/scripts/render_rebuilt_pages.sh . main.pdf 140
```

Check:

- Pages are not blank.
- Text is readable and not clipped.
- Scanned pages have been reconstructed as text, math, tables, and genuine figures instead of embedded full-page rendered scans.
- Raw page transcript blocks, repeated page headers, footers, page numbers, and artificial page-boundary artifacts are absent from final chapters.
- Figures and tables appear near their references.
- Formulas are legible.
- Captions and labels are clear.
- Section hierarchy is obvious.
- Book front matter, main matter, and back matter are in a coherent order when applicable.
- Table of contents, list of figures, list of tables, bibliography, appendix, index, and glossary pages are readable and consistent with the rebuilt structure when present.
- Tables do not overflow the page and are not left as plain text when structure is legible.
- Math-heavy pages have display math rendered as LaTeX math, not paragraph text.
- Formula-heavy pages previously affected by glyph or display placeholders have been re-rendered and compared against the source page images.
- Figures are not oversized, undersized, clipped, or detached from captions.
- The visual style matches `style-profile.md` well enough for the document type.
- No major content is duplicated or missing.

Compare against the source PDF for semantic coverage, not pixel identity.

## Clean-Room Build

For publication polish, prove the project does not depend on stale auxiliary files, absolute paths, missing assets, or hidden local state. Prefer strict findings so unresolved references, citations, missing files, undefined commands, package errors, and rerun warnings fail the gate:

```bash
path/to/pdf-to-latex/scripts/publication_gate.sh . main.tex --strict-findings
```

The helper runs a normal health check, optionally fails strict compile findings, scans final source for extraction artifacts, optionally renders rebuilt pages, copies the project to a temporary clean build directory, removes common LaTeX auxiliary files there, and compiles again. It is a deterministic gate, not a semantic reviewer.

If the helper is unavailable, approximate the gate manually:

1. Copy the project to a temporary directory.
2. Remove common generated files such as `.aux`, `.log`, `.out`, `.toc`, `.lof`, `.lot`, `.bbl`, `.bcf`, `.run.xml`, `.fls`, `.fdb_latexmk`, and existing PDFs.
3. Compile with XeLaTeX or `latexmk -xelatex`.
4. Run the artifact scan on final source.
5. Render or inspect representative rebuilt pages.

Record the command, result, clean build path if useful, and any warnings in `conversion-notes.md`. Do not mark publication polish complete when the clean-room build fails unless the failure is a documented true blocker approved by the user.

## Workflow Gate Check

For publication polish, run the workflow gate checker before final delivery:

```bash
path/to/pdf-to-latex/scripts/check_workflow_gates.sh .
```

The checker validates required state-file checkpoints, publication-polish acceptance gate values, profile-specific files, required notes sections, and obvious unfinished statuses such as blank, `pending`, or `in-progress` page/object states. Use:

```bash
path/to/pdf-to-latex/scripts/check_workflow_gates.sh . --allow-blocked
```

only when true blockers are documented and the final response will describe a blocked publication-polish delivery rather than claiming completion.

## Downgrade Or Blocker Policy

Do not silently downgrade `publication polish` to `clean semantic` or `rough draft`. When the source, toolchain, or available evidence prevents publication polish:

1. Continue fixing the issue when the content is visible, inferable, and reasonably repairable.
2. Mark a localized item `blocked` when a required page, formula, table, figure, citation, or build step cannot be resolved with available evidence.
3. Ask the user before downgrading the delivery level, leaving broad unresolved content, accepting full-page screenshots, skipping book/math gates, or treating unreadable source material as omitted.
4. If the user approves a lower delivery level, update `Delivery level:`, `conversion-state.md`, `conversion-notes.md`, and the acceptance gates; record which publication-polish gates were intentionally skipped.
5. If the user does not approve a downgrade and the blocker remains, stop with publication polish blocked and preserve the resumable state.

Use `omitted-with-reason` only for content that is outside the delivery contract, duplicated by generated structure, visibly irrelevant, or explicitly accepted by the user. Use `blocked` for required content that remains unresolved.

## Notes Review

`conversion-notes.md` should include:

- What was derived directly from the PDF.
- What was inferred visually.
- What was approximated.
- What came from optional digital text-layer extraction, when used.
- Batch plan and completed page or chapter ranges for long documents.
- Page transcript or page manifest status.
- Delivery contract, source completeness audit, asset discovery, and midpoint reviewer status for publication polish.
- Document IR, object inventory, and style profile status.
- Book production status, generated-list checks, cross-reference audit, appendix/bibliography handling, and index/glossary status when applicable.
- Task profile and any intentionally omitted heavy artifacts.
- Any profile upgrade such as `standard` to `book`, `math-heavy`, or `book-math`.
- Math inventory, glyph map, artifact counts, and formula-heavy pages reviewed when applicable.
- Polish passes completed and pages or sections reviewed.
- Production spec, skeleton compile, batch compile, midpoint reviewer, final reviewer, clean-room build, and workflow gate status.
- Quality rubric results.
- What came from public web sources, with links or citations when used.
- Known unresolved issues.
- Verification commands and results.

If the notes contain unresolved critical gaps, report them clearly in the final answer.

`conversion-state.md` should be consistent with the notes and filesystem:

- Current phase reflects the latest verified state.
- Completed checkpoints have corresponding evidence.
- Last successful command matches the latest successful compile or review command.
- Active files point to the files a future Codex agent should open next.
- Next action is concrete, or says `None; quality review complete`.

## Refinement Acceptance

Before delivering a refined project, confirm the checks required by the selected delivery level:

- The latest compile succeeds.
- For publication polish, the delivery contract, source completeness audit, asset discovery, skeleton compile, batch compile, midpoint reviewer, final reviewer, workflow gate, and clean-room build gates have passed or true blockers are documented.
- User-stated issues have been addressed or explicitly documented as unresolved.
- No new missing file, undefined command, or unresolved reference issue was introduced.
- Minimum refinement passes completed or explicitly marked not applicable.
- Final source is reconciled with the source completeness audit; required page and object statuses are not left broadly `pending`, `in-progress`, or unowned.
- `document-ir.md`, `object-inventory.md`, and `style-profile.md` are present when page-level reconstruction was used, or their omission is documented for small/simple documents.
- Final chapters align with the document IR rather than directly stitched page transcripts.
- Every major object in `object-inventory.md` is rebuilt, reviewed, or documented as unresolved.
- For math-heavy or encoded PDFs, `math-inventory.md` and `glyph-map.md` are reconciled with final source.
- Style decisions in `style-profile.md` are reflected in document class, sectioning, packages, and layout.
- For book-scale projects, `references/book-production.md` quality gates are complete or explicitly marked not applicable, and the source is not flattened into an article when the PDF has book structure.
- Table of contents, list of figures, list of tables, appendices, bibliography/references, index, and glossary are rebuilt, generated, or documented as unresolved according to source visibility and user request.
- Chapter, equation, figure, table, theorem-like, appendix, citation, and index/glossary references are resolved or documented as unresolved.
- Local OCR engines were not used.
- Full-page scanned-image placeholders are absent unless the user explicitly requested them.
- Raw transcript artifacts and obvious page-boundary artifacts are absent from final chapters.
- Final source contains no `\pdfglyph`, `extracteddisplay`, raw encoded math, or formula placeholder comments unless the user explicitly approved a rough draft or a specific documented unresolved item.
- Major tables, formulas, figures, captions, citations, and references use semantic LaTeX where legible.
- Severe overfull boxes, clipping, blank pages, huge whitespace, and bad float placement have been reviewed and fixed when reasonable.
- Representative rendered pages are readable and nonblank.
- High-risk pages or objects from the source completeness audit have been visually reviewed or documented as blocked.
- The project rebuilds from a clean copy or clean working tree state for publication polish.
- The workflow gate checker passes for publication polish, or `--allow-blocked` is used only for a documented blocked outcome.
- Key semantic content from the source PDF remains present after refinement.
- `conversion-notes.md` lists the refinement passes, commands, fixes, and remaining issues.

For a rough draft, explicitly list which clean-semantic or publication-polish checks remain. For publication polish, do not downgrade unresolved book or math quality gates into notes-only issues unless they are true blockers or the user approved the unresolved item.

## Delivery Checklist

Before final response:

- `main.tex` exists and is the project entry point.
- `conversion-state.md` exists and reflects the latest completed checkpoint.
- `page-manifest.md` and page transcripts exist when page-level visual transcription was used.
- `evidence/text-layer/` contains page-bounded text files when digital extraction was used as source evidence.
- `document-ir.md`, `object-inventory.md`, and `style-profile.md` exist when page-level reconstruction was used, or documented light-profile simplifications replace these files.
- Book front/back matter files or clearly documented book structure exist when book-scale reconstruction was used.
- Chapter, figure, and table files are referenced correctly.
- The compiled PDF exists.
- The latest compile command succeeded.
- Publication-polish clean-room build succeeded or a true blocker is documented.
- Publication-polish acceptance gates are recorded in `conversion-notes.md`.
- Publication-polish workflow gate check succeeded or is documented as blocked.
- Text extraction or manual inspection confirms key content.
- Temporary files outside the target project are cleaned up where practical.
- The final answer names the LaTeX project path, compiled PDF path, verification performed, and remaining uncertainties.

## Completion Standard

Complete a clean semantic or publication-polish task only when Goal-mode planning is recorded, the rebuilt PDF compiles, key semantic content is present, the document IR and object inventory have been reconciled with final LaTeX or their light-profile omission is documented, minimum refinement passes have been completed or explicitly marked not applicable, book-production gates pass when applicable, math artifact scans are clean when applicable, and the final chapters no longer look like raw page transcripts. Complete publication polish only when Goal-mode planning, the delivery contract, production spec, source completeness audit, skeleton compile, asset discovery, batch compile record, midpoint reviewer, final reviewer gates, visual comparison, artifact scans, workflow gate check, and clean-room build gate have passed or true blockers are documented. Complete a rough draft only when the user requested that level and the remaining work is recorded plainly. If a required system tool for verification is missing, stop and tell the user exactly what is missing and which verification step could not run.
