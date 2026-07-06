# Quality Review Reference

Use this reference before delivering a rebuilt LaTeX project. The quality bar is semantic completeness and readability, not pixel-level matching.

## Required Checks

1. Compile the project with XeLaTeX or an equivalent XeLaTeX-based command.
2. Inspect compile logs for missing files, undefined commands, unresolved references, overfull boxes, and font problems.
3. Extract text from the compiled PDF when possible and compare it with key source content.
4. Render or open the compiled PDF and check readability, page flow, figures, tables, formulas, and references.
5. Compare final chapters against `document-ir.md`, `object-inventory.md`, and `style-profile.md`.
6. Complete the quality rubric from `latex-refinement.md`.
7. Update `conversion-notes.md` with verification results, rubric status, and remaining uncertainties.
8. Update `conversion-state.md` with the latest successful command, completed quality checkpoints, and any remaining next action.
9. Confirm the minimum refinement passes from `latex-refinement.md` were completed or explicitly marked not applicable.
10. Confirm the workflow did not use local OCR engines such as `tesseract` or `ocrmypdf`; `pdftotext` is acceptable only for digital text-layer evidence or output verification.
11. For scanned PDFs, confirm the rebuilt output is semantic LaTeX content rather than full-page screenshot embedding, unless the user explicitly requested visual replication.

For normal PDF-to-LaTeX work, perform the minimum refinement passes after the first successful compile. The first compiling PDF is a checkpoint, not the default final deliverable.

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
- Key paragraphs or terms.
- Table headers and important cells.
- Formula identifiers or surrounding explanatory text.
- Figure captions.
- Bibliography entries or citation labels.
- Representative objects from `object-inventory.md`.

Do not require exact line breaks, pagination, or spacing.

## Visual Review

Render pages or inspect the PDF directly:

```bash
pdftoppm -png -r 140 rebuilt.pdf /tmp/rebuilt-pages/page
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
- Tables do not overflow the page and are not left as plain text when structure is legible.
- Math-heavy pages have display math rendered as LaTeX math, not paragraph text.
- Figures are not oversized, undersized, clipped, or detached from captions.
- The visual style matches `style-profile.md` well enough for the document type.
- No major content is duplicated or missing.

Compare against the source PDF for semantic coverage, not pixel identity.

## Notes Review

`conversion-notes.md` should include:

- What was derived directly from the PDF.
- What was inferred visually.
- What was approximated.
- What came from optional digital text-layer extraction, when used.
- Page transcript or page manifest status.
- Document IR, object inventory, and style profile status.
- Polish passes completed and pages or sections reviewed.
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

Before delivering a refined project, confirm:

- The latest compile succeeds.
- User-stated issues have been addressed or explicitly documented as unresolved.
- No new missing file, undefined command, or unresolved reference issue was introduced.
- Minimum refinement passes completed or explicitly marked not applicable.
- `document-ir.md`, `object-inventory.md`, and `style-profile.md` are present when page-level reconstruction was used, or their omission is documented for small/simple documents.
- Final chapters align with the document IR rather than directly stitched page transcripts.
- Every major object in `object-inventory.md` is rebuilt, reviewed, or documented as unresolved.
- Style decisions in `style-profile.md` are reflected in document class, sectioning, packages, and layout.
- Local OCR engines were not used.
- Full-page scanned-image placeholders are absent unless the user explicitly requested them.
- Raw transcript artifacts and obvious page-boundary artifacts are absent from final chapters.
- Major tables, formulas, figures, captions, citations, and references use semantic LaTeX where legible.
- Severe overfull boxes, clipping, blank pages, huge whitespace, and bad float placement have been reviewed and fixed when reasonable.
- Representative rendered pages are readable and nonblank.
- Key semantic content from the source PDF remains present after refinement.
- `conversion-notes.md` lists the refinement passes, commands, fixes, and remaining issues.

## Delivery Checklist

Before final response:

- `main.tex` exists and is the project entry point.
- `conversion-state.md` exists and reflects the latest completed checkpoint.
- `page-manifest.md` and page transcripts exist when page-level visual transcription was used.
- `document-ir.md`, `object-inventory.md`, and `style-profile.md` exist when page-level reconstruction was used.
- Chapter, figure, and table files are referenced correctly.
- The compiled PDF exists.
- The latest compile command succeeded.
- Text extraction or manual inspection confirms key content.
- Temporary files outside the target project are cleaned up where practical.
- The final answer names the LaTeX project path, compiled PDF path, verification performed, and remaining uncertainties.

## Completion Standard

Complete the task only when the rebuilt PDF compiles, key semantic content is present, the document IR and object inventory have been reconciled with final LaTeX, minimum refinement passes have been completed or explicitly marked not applicable, and the final chapters no longer look like raw page transcripts. If a required system tool for verification is missing, stop and tell the user exactly what is missing and which verification step could not run.
