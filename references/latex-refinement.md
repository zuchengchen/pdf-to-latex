# LaTeX Refinement Reference

Use this reference after Codex has generated a LaTeX project from a PDF, or when the user provides an existing PDF-derived LaTeX project that needs polishing. Refinement is part of the default workflow: do not stop at the first compiling draft unless the user explicitly asks for only a rough draft.

## Refinement Goal

Turn the generated LaTeX project into a clean, compiled, readable result that preserves the source PDF's semantic content. Prefer steady improvement through compile-review-edit loops over one large rewrite.

Refine for:

- Compile success and stable reruns.
- Correct document structure and reading order.
- Legible typography, margins, headings, lists, and spacing.
- Clean tables, figures, captions, formulas, citations, and references.
- Reduced overfull boxes, missing files, unresolved references, and obvious layout defects.
- Clear notes for approximations, uncertain content, and unresolved issues.

## Inputs

Use whichever inputs are available:

- Source PDF.
- Generated `latex/` project.
- Current compiled PDF.
- LaTeX logs such as `main.log`, `.fls`, `.aux`, `.out`, or bibliography logs.
- Rendered page images from the source and rebuilt PDFs.
- Extracted text from source and rebuilt PDFs.
- User-stated target changes.

If the source PDF is missing but a LaTeX project exists, refine against the compiled output and user instructions. Record the missing source in `conversion-notes.md`.

## Refinement Loop

1. Compile the current project with XeLaTeX or `latexmk -xelatex`.
2. Read the first hard failure before changing many files.
3. Fix one focused category of issues.
4. Recompile.
5. Inspect rendered output and extracted text.
6. Compare against the source PDF or user target.
7. Update `conversion-notes.md`.
8. Repeat until the quality review passes or remaining issues are explicitly documented.

Keep changes small enough that a failed compile can be traced to the last batch.

## Issue Order

Use this priority order:

1. Hard compile failures.
2. Missing included files, images, or bibliography assets.
3. Undefined commands, broken packages, bad fonts, and encoding problems.
4. Broken document structure, missing sections, duplicated text, or wrong reading order.
5. Tables, formulas, figures, captions, citations, and references.
6. Major readability issues: clipped content, huge whitespace, unreadable type, bad margins.
7. Warnings that matter: overfull boxes, unresolved references, and repeated rerun warnings.
8. Cosmetic polish requested by the user.

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
- Use normal LaTeX floats before manual placement.
- Prefer semantic sectioning over manual bold text.
- Use `booktabs`, `array`, `tabularx`, `longtable`, or landscape only when the table needs it.
- Use `\small`, `\footnotesize`, or column width adjustments sparingly for dense tables.
- Keep figures near their first reference and scale them to readable widths.
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
- Source pages or sections reviewed.
- Remaining uncertainties.
- Any web-sourced or inferred material.

The notes should let a future Codex agent continue refinement without re-discovering the same problems.

## Stop Conditions

Stop and ask when:

- Refinement would overwrite user edits outside the target LaTeX project.
- Required verification tools are missing and the user asked for verified output.
- The user requests pixel-perfect replication but the existing project is semantic and would need a different strategy.
- A remaining issue depends on information that is not visible, extractable, or reasonably inferable.

Otherwise continue refining with clear notes rather than stopping at the first imperfect draft.
