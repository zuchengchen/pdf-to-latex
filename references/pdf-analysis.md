# PDF Analysis Reference

Use this reference to understand the source PDF before rebuilding it in LaTeX. The goal is to produce enough evidence for a semantic reconstruction, not to reverse-engineer every drawing command.

## Analysis Goals

Capture:

- PDF path, page count, page sizes, orientation, and whether pages are digital, scanned, or mixed.
- Logical reading order, section hierarchy, and document metadata.
- Text layer quality: selectable text, broken encodings, ligature issues, missing whitespace, or damaged extraction.
- Figures, tables, formulas, captions, footnotes, headers, footers, references, and appendices.
- Pages or regions that need visual reasoning or approximation.
- Page-level route map for digital, scanned, mixed, and damaged-text reconstruction.
- Object inventory for figures, tables, formulas, citations, references, appendices, and unresolved visual regions.
- Style profile for the document type and LaTeX strategy.

Record findings in the target `latex/conversion-notes.md` as work proceeds. Also update `latex/conversion-state.md` after the first pass so interrupted work can resume without repeating PDF discovery.

## First Pass

1. Locate the PDF and decide the output directory.
2. If the output directory already exists, inspect `conversion-state.md`, `conversion-notes.md`, `main.tex`, existing rendered pages, extracted text, logs, and compiled PDFs before re-running analysis.
3. Check available local tools for PDF inspection and rendering, for example `pdfinfo`, `pdfseparate`, `pdftotext`, `pdftoppm`, `mutool draw`, or `pdfimages`. Do not use local OCR tools.
4. Inspect metadata and page count when tools are available:

```bash
pdfinfo source.pdf
```

5. For digital PDFs, optionally extract text-layer evidence:

```bash
pdftotext -layout source.pdf -
```

Use this only as draft evidence for selectable text, not as final LaTeX and not as OCR.

6. Split or render the PDF into page-level evidence. Render all pages for short and scanned PDFs.

```bash
pdfseparate source.pdf /tmp/pdf-pages/page-%03d.pdf
pdftoppm -png -r 160 source.pdf /tmp/pdf-pages/page
```

7. Visually compare rendered pages with any extracted text layer. Trust visual page images over broken text extraction.
8. Create or update `page-manifest.md` with per-page or per-region routes, evidence paths, optional text-layer extracts, and transcription status.
9. Create or update `object-inventory.md` and `style-profile.md` with the document objects and target LaTeX strategy discovered so far.
10. Update `conversion-state.md` with the current phase, completed analysis checkpoints, generated helper files, and the next reconstruction action.

## Classify The PDF

Use these categories:

- **Digital**: selectable text is mostly complete and in reading order. `pdftotext` may be used as optional text-layer evidence.
- **Scanned**: text extraction is empty or unusable; pages are images.
- **Mixed**: some pages or regions have usable text, while others require visual transcription.
- **Encoded or damaged text**: text exists but has scrambled characters, broken ligatures, missing spaces, or bad ordering.

For scanned, mixed, or damaged-text pages, use Codex visual reading from rendered page images as the transcription source. Do not use `tesseract`, `ocrmypdf`, local OCR engines, or cloud OCR APIs.

Rendered page images are analysis artifacts. Do not copy full-page renders into the LaTeX project as page screenshots unless the user explicitly asks for visual replication. The normal scanned-PDF path is Codex visual transcription followed by semantic LaTeX reconstruction.

## Reading Order

Determine reading order before writing LaTeX:

- Single column, multi-column, sidebars, footnotes, floating figures, and tables.
- Section titles and numbering.
- Captions and their associated figures or tables.
- Repeated headers and footers that should usually be omitted from semantic reconstruction.
- Page numbers, watermarks, stamps, or marginalia that should be included only if meaningful.

For multi-column pages, use the rendered image to infer natural reading flow. `pdftotext -layout` can help, but often interleaves columns incorrectly.

## Codex Visual Transcription Strategy

For scanned, mixed, damaged-text, or visually complex pages:

1. Render pages at a readable resolution, usually 180 to 220 DPI; rerender hard pages at 240 to 300 DPI when small text, formulas, or tables require it.
2. Provide Codex the page image, optional single-page PDF, optional neighboring-page context, and optional digital text-layer excerpt only when the page is digital.
3. Zoom into hard regions such as formulas, tables, captions, and footnotes.
4. Transcribe content semantically. Preserve paragraphs, section structure, formulas, table meaning, and citations rather than line breaks or page geometry.
5. Mark uncertain words, symbols, or table cells in `conversion-notes.md` and `conversion-state.md`.
6. Store page-level transcription evidence under `transcripts/` or reference it from `conversion-notes.md`.

If a digital text-layer extract and visual reading disagree, prefer the visible page unless external evidence proves otherwise.

Do not create a compileable draft by embedding each scanned page as `\includegraphics`. If a region cannot be read well enough, add a concise placeholder or LaTeX source comment and continue with the readable semantic content.

## Page Manifest

Create `page-manifest.md` before large-scale transcription. Keep it compact and update it as pages are assigned, transcribed, merged, or revisited.

Use this shape:

```text
# Page Manifest

Source PDF:
Rendered pages:
Single-page PDFs:
Digital text-layer extracts:

## Page Routes
- Page 001: digital | evidence: pages/page-001.png | text layer: available | status: pending
- Page 002: scanned | evidence: pages/page-002.png | text layer: none | status: pending
- Page 003: damaged-text | evidence: pages/page-003.png | text layer: unreliable | status: pending
```

For each page transcript, capture:

```text
Page:
Route:
LaTeX fragment:
Figures:
Tables:
Equations:
Continuity:
Uncertainties:
```

When permitted by the current system and user instructions, independent page batches may be delegated to subagents. Give each subagent a bounded batch, the relevant page images, optional digital text-layer excerpts, and the required page transcript format. The main agent must merge fragments, resolve cross-page continuity, and produce the final LaTeX project.

## Object Inventory

Create `object-inventory.md` before final LaTeX generation. Treat it as the checklist for high-value content that should not get lost during page merging.

Use this shape:

```text
# Object Inventory

Figures:
- id:
  source pages:
  caption:
  asset/crop needed:
  status:

Tables:
- id:
  source pages:
  caption:
  structure:
  status:

Equations:
- id or number:
  source pages:
  surrounding text:
  confidence:
  status:

References and citations:
- citation style:
- bibliography pages:
- unresolved citations:

Unresolved visual regions:
- source page:
  description:
  next action:
```

Update each object's status as `pending`, `transcribed`, `rebuilt`, `compiled`, `reviewed`, or `uncertain`. The final LaTeX should account for every major object or explicitly document why an object was omitted.

## Style Profile

Create `style-profile.md` before drafting `main.tex`. Choose a practical target style that helps the rebuilt LaTeX look authored rather than mechanically transcribed.

Capture:

```text
Document profile: article | academic paper | report | book chapter | thesis | manual | handout | form | math-heavy | table-heavy | CJK/multilingual | other
Document class:
Language and font needs:
Sectioning depth:
Bibliography strategy:
Figure strategy:
Table strategy:
Math strategy:
Layout notes:
Packages likely needed:
Packages to avoid unless necessary:
```

Use the profile to decide whether the baseline should stay minimal or add focused support such as `xeCJK`, `tabularx`, `longtable`, `siunitx`, `biblatex`, `multicol`, landscape pages, or theorem environments. If a package may be missing, prefer a portable fallback and record the decision.

## Figures And Images

Identify whether figures should be:

- Reused as extracted or cropped images.
- Recreated as LaTeX tables, TikZ, plots, or simple diagrams.
- Described or approximated when extraction is poor.

Use `pdfimages` if available for embedded assets, or crop only the actual figure or diagram from rendered pages when the embedded asset is not accessible. Preserve figure numbers and captions. Put reusable image files under `latex/figures/`. Do not put full scanned pages under `latex/figures/` as placeholders.

## Tables

For each table, capture:

- Caption or label.
- Column headers.
- Row labels and data.
- Units and footnotes.
- Whether table structure is certain or inferred.

Prefer semantic LaTeX tables over screenshot tables when the content is legible. For complex or partially illegible tables, rebuild the clear parts and mark uncertain cells.

## Formulas

For formulas and equations:

- Identify inline math, display equations, numbering, and symbols.
- Prefer standard LaTeX math notation over visual positioning.
- Mark uncertain symbols explicitly, for example `% uncertain: symbol may be \alpha or a`.
- Use public web lookup for standard formulas or public papers only when it materially improves accuracy, and record the source.

## References And Citations

Detect citation style and bibliography structure. Extract references from the PDF when possible. Public web lookup is allowed for DOI, arXiv, title, author, venue, or BibTeX cleanup, but label the source of any added metadata.

Do not silently replace PDF references with web versions. Preserve PDF-derived reference text unless the user asks for normalization.

## Analysis Output

Before rebuilding, maintain a concise working map:

```text
Document type:
Pages:
Text layer:
Scanned or visual-only regions:
Page/region route map:
Page evidence:
Optional digital text-layer extracts:
Object inventory:
Style profile:
Structure:
Figures:
Tables:
Formulas:
References:
Uncertainties:
External sources used:
```

This map can live in `conversion-notes.md` and evolve during reconstruction.

For resumability, keep `conversion-state.md` shorter and action-oriented:

```text
Current phase: analysis complete
Completed checkpoints:
- PDF located
- Tool availability checked
- Page count and text layer inspected
- Representative pages rendered
- Page manifest created
- Object inventory created
- Style profile created
- Document IR inputs identified
Last successful command:
Active files:
Next action: transcribe page batches or build document IR
Blockers or uncertainties:
```

If resuming and these checkpoints are already satisfied, verify the referenced files still exist and continue with the next action instead of redoing the whole analysis.
