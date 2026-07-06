# LaTeX Refinement Reference

Use this reference after Codex has generated a LaTeX project from a PDF, or when the user provides an existing PDF-derived LaTeX project that needs polishing. Refinement is part of the default workflow: do not stop at the first compiling draft unless the user explicitly asks for only a rough draft.

## Refinement Goal

Turn the generated LaTeX project into a clean, compiled, readable result that preserves the source PDF's semantic content and reads like a normal authored LaTeX document, not a stitched set of page transcripts. Prefer steady improvement through compile-review-edit loops over one large rewrite.

Refine for:

- Compile success and stable reruns.
- Correct document structure and reading order.
- Removal of page-level transcript artifacts, page headers, page footers, duplicated headings, and artificial page breaks.
- Legible typography, margins, headings, lists, and spacing.
- Clean tables, figures, captions, formulas, citations, and references.
- Replacement of any full-page scanned-image placeholders with semantic text, math, tables, and real figure assets unless the user explicitly requested visual replication.
- Reduced overfull boxes, missing files, unresolved references, and obvious layout defects.
- Clear notes for approximations, uncertain content, and unresolved issues.

## Inputs

Use whichever inputs are available:

- Source PDF.
- Generated `latex/` project.
- `conversion-state.md` with current phase, completed checkpoints, and next action.
- Current compiled PDF.
- LaTeX logs such as `main.log`, `.fls`, `.aux`, `.out`, or bibliography logs.
- Rendered page images from the source and rebuilt PDFs.
- Page transcripts, page fragments, and optional digital text-layer extracts.
- Extracted text from rebuilt PDFs.
- User-stated target changes.

If the source PDF is missing but a LaTeX project exists, refine against the compiled output and user instructions. Record the missing source in `conversion-notes.md`.

When resuming an interrupted project, read `conversion-state.md` first. If it is missing, infer a starting state from `main.tex`, logs, compiled PDFs, and `conversion-notes.md`, then create the state file before editing.

## Refinement Loop

1. Read or create `conversion-state.md` and choose the next focused action from it.
2. Compile the current project with XeLaTeX or `latexmk -xelatex`.
3. Read the first hard failure before changing many files.
4. Record the failure summary and intended fix in `conversion-state.md`.
5. Fix one focused category of issues or run the next polish pass below.
6. Recompile.
7. Inspect rendered output and extracted text.
8. Compare against the source PDF or user target.
9. Update `conversion-notes.md` and `conversion-state.md`.
10. Repeat until the quality review passes or remaining issues are explicitly documented.

Keep changes small enough that a failed compile can be traced to the last batch.

## Polish Passes

After the first successful compile, run focused polish passes. The first compiling PDF is a checkpoint, not the normal final deliverable.

1. **Transcript Merge Pass**: remove raw page transcript boundaries, join paragraphs split across pages, remove repeated page headers, footers, page numbers, duplicated headings, and page-end artifacts.
2. **Structure Pass**: convert visual headings into `\section`, `\subsection`, and lists; normalize title, author, abstract, appendices, footnotes, citations, and references.
3. **LaTeX Idiom Pass**: replace rough plain text with semantic environments such as `equation`, `align`, `figure`, `table`, `tabular`, `longtable`, `itemize`, `enumerate`, `quote`, and `thebibliography` where appropriate.
4. **Object Polish Pass**: refine tables, formulas, figures, captions, labels, references, cross-references, units, and notes. Fix table-like plain text and display math left as ordinary paragraphs when legible.
5. **Typography Pass**: tune margins, heading spacing, paragraph flow, figure sizes, table widths, float placement, severe overfull boxes, clipped content, blank pages, and awkward whitespace.
6. **Visual Comparison Pass**: render the rebuilt PDF, compare representative pages against the source PDF for semantic coverage and readability, and revisit pages marked uncertain in `page-manifest.md` or `conversion-notes.md`.
7. **Final Cleanup Pass**: remove temporary transcript comments that are no longer useful, stale `\input` lines, unused labels, duplicate macros, and unresolved placeholders that can be fixed. Keep necessary uncertainty comments concise.

For small documents, complete every applicable pass. For long documents, complete at least the minimum refinement below and sample high-risk pages: title or first page, one normal body page, one table-heavy page, one formula-heavy page, references or appendices, and every page marked uncertain.

## Minimum Refinement

Unless the user explicitly requests a rough draft, complete at least:

- One compile-fix pass after the first failed or successful compile.
- One transcript merge and structure pass.
- One LaTeX idiom or object polish pass for the roughest formulas, tables, figures, and references.
- One typography and visual review pass over rendered output.
- One final notes and state update naming completed passes and remaining issues.

Do not deliver while raw transcript blocks, obvious page-boundary artifacts, severe layout defects, or unresolved compile problems remain fixable with reasonable effort.

## Issue Order

Use this priority order:

1. Hard compile failures.
2. Missing included files, images, or bibliography assets.
3. Undefined commands, broken packages, bad fonts, and encoding problems.
4. Broken document structure, missing sections, duplicated text, or wrong reading order.
5. Missing, duplicated, or poorly merged page transcripts.
6. Raw transcript blocks, page-boundary artifacts, repeated headers, footers, page numbers, and artificial page breaks.
7. Full-page scanned-image placeholders that should be semantic content.
8. Table-like plain text, display math left as plain text, missing captions, missing labels, or rough citations.
9. Tables, formulas, figures, captions, citations, and references.
10. Major readability issues: clipped content, huge whitespace, unreadable type, bad margins, oversized figures, undersized tables, and poor float placement.
11. Warnings that matter: severe overfull boxes, unresolved references, and repeated rerun warnings.
12. Cosmetic polish requested by the user.

Do not spend time chasing harmless warnings when semantic defects remain.

## Compile Fixes

For compile failures:

- Escape LaTeX special characters in text.
- Add missing packages only when they solve a real source issue.
- Replace unavailable fonts with portable fallbacks using `\IfFontExistsTF`.
- Fix image paths relative to `main.tex`.
- Remove or repair stale `\input`, `\includegraphics`, `\ref`, and `\cite` targets.
- Simplify bibliography tooling if the local toolchain cannot support the first choice.

Record package or font substitutions in `conversion-notes.md`.

## Layout And Readability

Improve readability without trying to trace every pixel:

- Adjust `geometry` margins only when content is cramped or source proportions clearly require it.
- Remove artificial `\newpage`, `\clearpage`, and page-level section breaks that only came from transcript boundaries.
- Use normal LaTeX floats before manual placement.
- Prefer semantic sectioning over manual bold text.
- Use `booktabs`, `array`, `tabularx`, `longtable`, or landscape only when the table needs it.
- Use `\small`, `\footnotesize`, or column width adjustments sparingly for dense tables.
- Keep figures near their first reference and scale them to readable widths.
- Fix severe overfull boxes and obvious clipping before cosmetic spacing.
- Avoid absolute positioning unless the user asks for visual recreation.

## Content Refinement

Compare the rebuilt PDF with the source PDF for semantic coverage:

- Title, authors, abstract, and section headings.
- Main paragraphs and key terms.
- Figures, captions, and figure references.
- Table headers, units, important cells, and notes.
- Formulas, equation numbering, and surrounding explanation.
- Citations, bibliography entries, appendices, and footnotes.

When content is unclear, improve the best available reconstruction and mark uncertainty. Do not silently invent exact text.

For scanned PDFs, full-page rendered images are not acceptable as the normal final content. Replace them with Codex visual transcriptions, semantic tables, LaTeX math, and cropped real figures. If a region remains unreadable, leave a concise placeholder or source comment and record the uncertainty instead of keeping a page screenshot.

For page-derived drafts, de-page the content before delivery:

- Join cross-page paragraphs and references.
- Remove running headers, footers, and repeated page numbers.
- Move captions next to their figures or tables.
- Merge split tables only when structure is clear; otherwise document the split or uncertainty.
- Convert bold or centered visual headings into semantic sectioning.
- Preserve meaningful page breaks only for title pages, appendices, large tables, or user-requested visual structure.

## Tables

Refine tables by:

- Restoring headers, units, captions, labels, and notes.
- Aligning numeric columns sensibly.
- Replacing screenshot tables with semantic LaTeX when the content is legible.
- Splitting or rotating large tables only when necessary.
- Marking uncertain cells with source comments and notes.

## Formulas

Refine formulas by:

- Using standard math environments.
- Fixing missing superscripts, subscripts, fractions, Greek symbols, delimiters, and equation numbers.
- Checking extracted text against rendered math because PDF text extraction often loses math structure.
- Using public sources only when the formula is standard or publicly identifiable, and record the source.

## Figures

Refine figures by:

- Ensuring image files exist and compile.
- Cropping or replacing poor captures when better assets can be extracted.
- Adjusting width for readability.
- Preserving captions and labels.
- Recreating simple diagrams or plots semantically when faster and clearer than a screenshot.

## Notes During Refinement

Update `conversion-notes.md` after each meaningful pass with:

- Compile command and result.
- Files changed.
- Issues fixed.
- Polish pass completed.
- Source pages or sections reviewed.
- Remaining uncertainties.
- Any web-sourced or inferred material.

The notes should let a future Codex agent continue refinement without re-discovering the same problems.

Update `conversion-state.md` more frequently and more compactly:

- After each failed compile diagnosis, set `Current phase` to the relevant repair phase and set `Next action` to the next fix.
- After each successful compile, record the command, output PDF path, and next review action.
- After each focused refinement pass, mark the completed checkpoint and name the next unresolved category.
- During polishing, record the latest completed pass: transcript merge, structure, LaTeX idiom, object polish, typography, visual comparison, or final cleanup.
- Before stopping or delivering, leave `Next action` as either the remaining concrete task or `None; quality review complete`.

Do not leave the state file saying a phase is complete unless the corresponding file, compile output, or review evidence exists.

## Stop Conditions

Stop and ask when:

- Refinement would overwrite user edits outside the target LaTeX project.
- Required verification tools are missing and the user asked for verified output.
- The user requests pixel-perfect replication but the existing project is semantic and would need a different strategy.
- A remaining issue depends on information that is not visible, extractable, or reasonably inferable.

Otherwise continue refining with clear notes rather than stopping at the first imperfect draft.
