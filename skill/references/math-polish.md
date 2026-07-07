# Math Publication Polish Reference

Use this reference for math-heavy PDFs, damaged text layers with custom encoded symbols, or any generated project that contains rough math extraction artifacts. A compiling PDF with unresolved math extraction artifacts is a draft checkpoint, not a near-publication final result.

## Contents

- Blocking Artifacts
- Required Tracking Files
- Artifact Census
- Cleanup Workflow
- Visual Identification
- Environment Selection
- Acceptance Standard

## Blocking Artifacts

Unless the user explicitly asks for a rough draft or approves documented unresolved artifacts, final source files must not contain:

- `\pdfglyph{...}` or equivalent raw glyph placeholder macros.
- `extracteddisplay` blocks or other placeholder display-math wrappers.
- Raw encoded math fragments copied from `pdftotext` without visual correction.
- `TODO math`, `unresolved glyph`, `raw glyph`, or similar placeholder notes in final chapters.
- Legible display equations left as paragraphs or verbatim transcript text.

It is acceptable for transcripts or scratch notes to preserve rough evidence, but `main.tex`, `chapters/`, `tables/`, bibliography files, and final included source must be cleaned before delivery.

## Required Tracking Files

For math-heavy documents or any project with glyph/display artifacts, create these files next to `object-inventory.md`:

```text
math-inventory.md
glyph-map.md
```

Use `math-inventory.md` to track formulas, equation numbers, symbols, and unresolved math regions:

```text
# Math Inventory

Source PDF:

Display equations:
- id or number:
  source page:
  surrounding text:
  current source file:
  status: pending | rebuilt | compiled | visually reviewed | blocked
  notes:

Inline math and symbol hotspots:
- source page:
  context:
  issue:
  status:

Artifact counts:
- pdfglyph:
- extracteddisplay:
- raw math placeholders:

Blocked items:
- source page:
  visible evidence:
  question:
```

Use `glyph-map.md` to resolve recurring encoded glyphs before doing one-off edits:

```text
# Glyph Map

Raw marker:
Source page:
Visual symbol:
LaTeX replacement:
Confidence: high | medium | low
Examples reviewed:
Replacement scope: global | chapter | local only
Notes:
```

Do not apply a global glyph replacement from a single weak example. Review multiple occurrences or restrict the replacement to the local formula where it is visually justified.

## Artifact Census

Before and after each math polish batch, scan final source files:

```bash
rg -n '\\pdfglyph|extracteddisplay|TODO math|unresolved glyph|raw glyph|MATH_PLACEHOLDER' main.tex chapters/ tables/ 2>/dev/null
```

When the bundled helper is available, prefer it because it scans project LaTeX and bibliography source while excluding transcript, evidence, and log directories:

```bash
path/to/pdf-to-latex/scripts/check_latex_artifacts.sh .
```

Record counts in `math-inventory.md` and `conversion-notes.md`. If the count is nonzero, keep the project in math polish or blocked-review status; do not mark quality review complete by default.

## Cleanup Workflow

1. Build an artifact census from final source files, LaTeX logs, rendered pages, and source PDF page images.
2. Group recurring glyph markers in `glyph-map.md`. Prefer high-frequency symbols first because one verified map can clean many formulas.
3. For each glyph group, inspect the source page image at readable resolution. Use neighboring formulas, prose, equation numbering, and standard notation to identify the visible symbol.
4. Replace confirmed glyphs with standard LaTeX such as `\alpha`, `\partial`, `\mathcal{L}`, `\dagger`, `\hbar`, `\cdot`, `\times`, or relation symbols.
5. Convert each `extracteddisplay` or placeholder display block into a proper math environment: `equation`, `align`, `gather`, `multline`, `split`, `cases`, or theorem-related environments when appropriate.
6. Preserve equation numbers, tags, labels, and surrounding references. Add labels when the source refers to an equation and no stable label exists yet.
7. Recompile after each chapter or focused batch. Fix syntax errors immediately before continuing.
8. Render representative formula-heavy pages from the rebuilt PDF and visually compare them with source pages.
9. Update `math-inventory.md`, `glyph-map.md`, `conversion-notes.md`, and `conversion-state.md`.
10. Repeat until artifact scans are clean and the reviewed formulas are readable.

Use subagents for independent chapter or page-batch math review when the environment permits it. The main agent owns the shared `glyph-map.md`, merges replacements, compiles, and resolves conflicts.

## Visual Identification

Use Codex visual reading from rendered page images as the authority for damaged or custom encoded math. Optional `pdftotext` can show nearby words or recurring raw markers, but it is not reliable for math structure or custom symbols.

When a symbol is hard to identify:

- Zoom or rerender the source page at higher resolution.
- Inspect the same symbol in nearby formulas or later derivations.
- Check whether the prose names the symbol.
- Compare with standard notation for the topic.
- Use public web lookup only for public, standard, or identifiable formulas, and record the source in `conversion-notes.md`.

Do not silently invent exact symbols. If the visible evidence is still insufficient, mark the item as blocked with the source page and question, then ask the user rather than completing the project as publication-grade.

## Environment Selection

Choose math environments by meaning:

- `equation` for one numbered display equation.
- `equation*` or `\[...\]` for unnumbered single display equations.
- `align` or `align*` for aligned derivations or multiple related equations.
- `aligned` inside `equation` when one equation number covers several aligned lines.
- `gather` for centered multi-line equations without alignment points.
- `multline` for one long equation broken across lines.
- `cases` for piecewise definitions.
- `theorem`, `lemma`, `definition`, or `proof` environments when the source uses formal math prose and the project preamble supports them.

Avoid forcing every display into `equation`. Use `\tag{...}` sparingly to preserve source numbering when automatic numbering would diverge.

## Acceptance Standard

For near-publication delivery, require all of the following:

- Artifact scan of final source returns no `\pdfglyph`, `extracteddisplay`, or raw math placeholders.
- `math-inventory.md` shows every major display equation as rebuilt, compiled, and reviewed, or explicitly blocked with a user-facing question.
- `glyph-map.md` records recurring glyph decisions and confidence.
- Representative formula-heavy pages have been visually compared against the source PDF.
- Equation numbering, labels, and references are preserved where visible and meaningful.
- Remaining uncertainty is small, localized, and clearly documented; broad counts such as hundreds of glyph markers or placeholder display blocks are not acceptable final quality.
