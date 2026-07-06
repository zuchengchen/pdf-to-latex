# PDF Analysis Reference

Use this reference to understand the source PDF before rebuilding it in LaTeX. The goal is to produce enough evidence for a semantic reconstruction, not to reverse-engineer every drawing command.

## Analysis Goals

Capture:

- PDF path, page count, page sizes, orientation, and whether pages are digital, scanned, or mixed.
- Logical reading order, section hierarchy, and document metadata.
- Text layer quality: selectable text, broken encodings, ligature issues, missing whitespace, or OCR noise.
- Figures, tables, formulas, captions, footnotes, headers, footers, references, and appendices.
- Pages or regions that need visual reasoning or approximation.

Record findings in the target `latex/conversion-notes.md` as work proceeds.

## First Pass

1. Locate the PDF and decide the output directory.
2. Check available local tools, for example `pdfinfo`, `pdftotext`, `pdftoppm`, `pdfimages`, `tesseract`, or `ocrmypdf`.
3. Inspect metadata and page count when tools are available:

```bash
pdfinfo source.pdf
pdftotext -layout source.pdf -
```

4. Render representative pages for visual review. Render all pages for short PDFs.

```bash
pdftoppm -png -r 160 source.pdf /tmp/pdf-pages/page
```

5. Visually compare rendered pages with extracted text. Trust visual page images over broken text extraction.

## Classify The PDF

Use these categories:

- **Digital**: selectable text is mostly complete and in reading order.
- **Scanned**: text extraction is empty or unusable; pages are images.
- **Mixed**: some pages or regions have usable text, while others require visual transcription.
- **Encoded or damaged text**: text exists but has scrambled characters, broken ligatures, missing spaces, or bad ordering.

For scanned or damaged pages, prioritize Codex visual reading from rendered page images. Local OCR may help, but it should not replace visual judgment when OCR output is noisy.

## Reading Order

Determine reading order before writing LaTeX:

- Single column, multi-column, sidebars, footnotes, floating figures, and tables.
- Section titles and numbering.
- Captions and their associated figures or tables.
- Repeated headers and footers that should usually be omitted from semantic reconstruction.
- Page numbers, watermarks, stamps, or marginalia that should be included only if meaningful.

For multi-column pages, use the rendered image to infer natural reading flow. `pdftotext -layout` can help, but often interleaves columns incorrectly.

## Visual OCR Strategy

For scanned pages:

1. Render pages at a readable resolution, usually 160 to 220 DPI.
2. Zoom into hard regions such as formulas, tables, captions, and footnotes.
3. Transcribe content semantically. Preserve paragraphs and math meaning rather than line breaks.
4. Use local OCR only as a second opinion or bulk draft when available.
5. Mark uncertain words, symbols, or table cells in `conversion-notes.md`.

If OCR and visual reading disagree, prefer the visible page unless external evidence proves otherwise.

## Figures And Images

Identify whether figures should be:

- Reused as extracted or cropped images.
- Recreated as LaTeX tables, TikZ, plots, or simple diagrams.
- Described or approximated when extraction is poor.

Use `pdfimages` if available for embedded assets, or crop from rendered pages when the embedded asset is not accessible. Preserve figure numbers and captions. Put reusable image files under `latex/figures/`.

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
Structure:
Figures:
Tables:
Formulas:
References:
Uncertainties:
External sources used:
```

This map can live in `conversion-notes.md` and evolve during reconstruction.
