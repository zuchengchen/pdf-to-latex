# Quality Review Reference

Use this reference before delivering a rebuilt LaTeX project. The quality bar is semantic completeness and readability, not pixel-level matching.

## Required Checks

1. Compile the project with XeLaTeX or an equivalent XeLaTeX-based command.
2. Inspect compile logs for missing files, undefined commands, unresolved references, overfull boxes, and font problems.
3. Extract text from the compiled PDF when possible and compare it with key source content.
4. Render or open the compiled PDF and check readability, page flow, figures, tables, formulas, and references.
5. Update `conversion-notes.md` with verification results and remaining uncertainties.

For normal PDF-to-LaTeX work, perform at least one refinement pass after the first successful compile. The first compiling PDF is a checkpoint, not the default final deliverable.

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

Do not require exact line breaks, pagination, or spacing.

## Visual Review

Render pages or inspect the PDF directly:

```bash
pdftoppm -png -r 140 rebuilt.pdf /tmp/rebuilt-pages/page
```

Check:

- Pages are not blank.
- Text is readable and not clipped.
- Figures and tables appear near their references.
- Formulas are legible.
- Captions and labels are clear.
- Section hierarchy is obvious.
- No major content is duplicated or missing.

Compare against the source PDF for semantic coverage, not pixel identity.

## Notes Review

`conversion-notes.md` should include:

- What was derived directly from the PDF.
- What was inferred visually.
- What was approximated.
- What came from public web sources, with links or citations when used.
- Known unresolved issues.
- Verification commands and results.

If the notes contain unresolved critical gaps, report them clearly in the final answer.

## Refinement Acceptance

Before delivering a refined project, confirm:

- The latest compile succeeds.
- User-stated issues have been addressed or explicitly documented as unresolved.
- No new missing file, undefined command, or unresolved reference issue was introduced.
- Representative rendered pages are readable and nonblank.
- Key semantic content from the source PDF remains present after refinement.
- `conversion-notes.md` lists the refinement passes, commands, fixes, and remaining issues.

## Delivery Checklist

Before final response:

- `main.tex` exists and is the project entry point.
- Chapter, figure, and table files are referenced correctly.
- The compiled PDF exists.
- The latest compile command succeeded.
- Text extraction or manual inspection confirms key content.
- Temporary files outside the target project are cleaned up where practical.
- The final answer names the LaTeX project path, compiled PDF path, verification performed, and remaining uncertainties.

## Completion Standard

Complete the task only when the rebuilt PDF compiles, the key semantic content is present, and at least one refinement pass has checked or improved the generated LaTeX. If a required system tool for verification is missing, stop and tell the user exactly what is missing and which verification step could not run.
