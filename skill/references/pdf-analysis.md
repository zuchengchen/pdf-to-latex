# PDF Analysis Reference

Use this reference to understand the source PDF before rebuilding it in LaTeX. The goal is to produce enough evidence for a semantic reconstruction, not to reverse-engineer every drawing command.

## Contents

- Analysis Goals
- Pre-Scaffold First Pass
- Durable Analysis Pass
- Classify The PDF
- Delivery Contract Inputs
- Production Spec Inputs
- Reading Order
- Codex Visual Transcription Strategy
- Long Document Batching
- Profile Upgrade Checklist
- Page Manifest
- Source Completeness Audit
- Object Inventory
- Style Profile
- Book Production Signals
- Figures And Images
- Tables
- Formulas
- References And Citations
- Analysis Output

## Analysis Goals

Capture:

- PDF path, page count, page sizes, orientation, and whether pages are digital, scanned, or mixed.
- Selected task profile: `light`, `standard`, `book`, `math-heavy`, or `book-math`.
- Selected delivery level and publication-polish acceptance contract when applicable.
- Logical reading order, section hierarchy, and document metadata.
- Text layer quality: selectable text, broken encodings, ligature issues, missing whitespace, or damaged extraction.
- Figures, tables, formulas, captions, footnotes, headers, footers, references, appendices, and book-scale structures.
- Pages or regions that need visual reasoning or approximation.
- Page-level route map for digital, scanned, mixed, and damaged-text reconstruction.
- Object inventory for figures, tables, formulas, citations, references, appendices, front matter, back matter, index/glossary, cross-references, and unresolved visual regions.
- Source completeness status that reconciles pages, regions, objects, IR blocks, and unresolved omissions before broad drafting.
- Math inventory and glyph-map needs for math-heavy PDFs, custom encoded symbols, or damaged formula extraction.
- Style profile for the document type and LaTeX strategy.

Record findings in the target `latex/conversion-notes.md` as work proceeds. Also update `latex/conversion-state.md` after the durable analysis pass so interrupted work can resume without repeating PDF discovery.

## Pre-Scaffold First Pass

1. Locate the PDF and decide the output directory.
2. If the output directory already exists, inspect `conversion-state.md`, `conversion-notes.md`, `main.tex`, existing rendered pages, extracted text, logs, and compiled PDFs before re-running analysis.
3. Check available local tools for PDF inspection and rendering, for example `pdfinfo`, `pdfseparate`, `pdftotext`, `pdftoppm`, `mutool draw`, or `pdfimages`. Do not use local OCR tools.
4. Inspect metadata and page count when tools are available:

```bash
pdfinfo source.pdf
```

5. Sample the first page's text layer when `pdftotext` is available and the PDF appears selectable; for visually complex, scanned, long, or book-like PDFs, render representative pages to a temporary location when needed before scaffolding.
6. Choose a provisional task profile before scaffolding. Use the exact helper values `light`, `standard`, `book`, `math-heavy`, or `book-math`. Choose a delivery level before broad reconstruction: `rough draft`, `clean semantic`, or `publication polish`. If the quick evidence is inconclusive, start with `standard` and `clean semantic`, then upgrade later after deeper analysis. For book-scale or math-heavy work, default to `publication polish` unless the user explicitly requests a lower delivery level. When using `publication polish`, record the acceptance contract after scaffolding before broad work.
7. Run Mandatory Goal Mode Planning from `SKILL.md`. For `goal-required` work, create or continue the Goal before broad transcription when tools and policy allow it; otherwise record `goal-unavailable-fallback` or stop for required approval. Do not commit to full-page transcription until this is settled.
8. For a new target directory, use `scripts/init_latex_project.sh` or the bundled `assets/templates/` files to create the scaffold with the provisional task profile and delivery level before recording durable analysis.

Keep this pass short. Its job is to choose a safe target, task profile, and delivery level, not to finish the analysis.

## Durable Analysis Pass

After the scaffold exists, record durable findings in `conversion-notes.md` and update `conversion-state.md`.

1. Add a feasibility note for long, scanned, mixed, math-heavy, encoded, or book-scale PDFs. Include page count, estimated scanned or visually complex pages, selected delivery level, first milestone, batch size, initial production-spec assumptions, Goal-mode decision, active Goal status, and any `goal-unavailable-fallback` reason.
2. For digital PDFs, optionally extract page-bounded text-layer evidence under the project:

```bash
mkdir -p latex/evidence/text-layer
pdftotext -f 1 -l 1 -layout source.pdf latex/evidence/text-layer/page-001.txt
scripts/extract_text_pages.sh source.pdf latex --pages 1,3,5-8
```

Use this only as draft evidence for selectable text, not as final LaTeX and not as OCR. Prefer page-bounded files such as `page-001.txt` over one giant text dump because they align with rendered page evidence and `page-manifest.md`.

3. Split or render the PDF into stable page-level evidence under the target project. Render all pages for short PDFs and for scanned PDFs only when the page count is practical. For long PDFs, render representative pages first, confirm or upgrade the profile and transcription plan, then render page batches as needed. Prefer `scripts/render_pdf_pages.sh` when available because it keeps logs and normalizes image names to `page-001.png` style. The helper supports full renders, `--pages 1,3,5-8`, and `--from START --to END`; it refuses to overwrite existing selected evidence unless `--force` is provided.

```bash
mkdir -p latex/evidence/source-pages
pdfseparate source.pdf latex/evidence/source-pages/page-%03d.pdf
pdftoppm -png -r 160 source.pdf latex/evidence/source-pages/page
scripts/render_pdf_pages.sh source.pdf latex 180 --pages 1,3,5-8
```

4. Visually compare rendered pages with any extracted text layer. Trust visual page images over broken text extraction.
5. Create or update `page-manifest.md` with per-page or per-region routes, evidence paths, optional text-layer extracts, batch assignment, and reconstruction status. Treat this as the evidence and route gate for publication polish.
6. Create or update `object-inventory.md` and `style-profile.md` with the document objects, selected task profile, production spec, and target LaTeX strategy discovered so far. For a light task, a concise outline and object list inside `conversion-notes.md` may replace standalone inventory or IR files; record why the omitted files would not improve review or resume. When the PDF is a book, textbook, technical monograph, proceedings volume, thesis, dissertation, or contains front matter, table of contents, list of figures/tables, appendices, bibliography, glossary, or index, read `references/book-production.md` and record the book profile. For math-heavy or encoded PDFs, also create `math-inventory.md` and `glyph-map.md` stubs before reconstruction.
7. For `publication polish`, run the source completeness audit before broad reconstruction. Reconcile page routes, object inventory, style profile, and `document-ir.md`; mark each page, region, and major object as `pending`, `in-progress`, `rebuilt`, `reviewed`, `blocked`, or `omitted-with-reason`.
8. Update `conversion-state.md` with the current phase, completed analysis checkpoints, generated helper files, source completeness status, and the next reconstruction action.

## Classify The PDF

Use these categories:

- **Digital**: selectable text is mostly complete and in reading order. `pdftotext` may be used as optional text-layer evidence.
- **Scanned**: text extraction is empty or unusable; pages are images.
- **Mixed**: some pages or regions have usable text, while others require visual transcription.
- **Encoded or damaged text**: text exists but has scrambled characters, broken ligatures, missing spaces, or bad ordering.
- **Encoded math layer**: prose may extract acceptably, but formulas contain custom-encoded symbols, missing operators, raw glyph codes, or display blocks that need visual reconstruction.
- **Book-scale structure**: the PDF has parts, chapters, front matter, generated lists, appendices, bibliography, index/glossary, or chapter-scoped numbering that need `references/book-production.md`.

For scanned, mixed, or damaged-text pages, use Codex visual reading from rendered page images as the transcription source. Do not use `tesseract`, `ocrmypdf`, local OCR engines, or cloud OCR APIs.

For encoded math layers, treat the text extraction as evidence for nearby prose and recurring markers only. Use rendered page images and `references/math-polish.md` to identify symbols and rebuild formulas.

Rendered page images are analysis artifacts. Do not copy full-page renders into the LaTeX project as page screenshots unless the user explicitly asks for visual replication. The normal scanned-PDF path is Codex visual transcription followed by semantic LaTeX reconstruction.

## Delivery Contract Inputs

For `publication polish`, record the acceptance contract in `conversion-notes.md` before broad work:

- Semantic fidelity target: what must be preserved from the PDF, including text, math, tables, figures, captions, references, front/back matter, bibliography, glossary, and index when present.
- Typography/layout target: readable publication-style LaTeX, near-source visual hierarchy, exact pagination, or another explicit target.
- Approximation policy: what may be inferred, simplified, cropped, recreated, or documented instead of perfectly rebuilt.
- Blocking policy: which unresolved content requires asking the user before delivery.
- Verification plan: skeleton compile, batch compiles, source completeness audit, reviewer gates, visual comparison, artifact scans, and clean-room build.

For `clean semantic`, keep a shorter delivery note in `conversion-notes.md` that names the expected compile/review floor and any intentionally skipped publication gates. For `rough draft`, record that the user requested a lower bar and list the checks that will remain incomplete.

## Production Spec Inputs

For `publication polish`, gather enough evidence before broad transcription to define the production target:

- Document class family: `article`, `report`, `book`, `ctexbook`, thesis class, proceedings structure, or another justified choice.
- Page geometry, one-sided or two-sided intent, margins, heading depth, and float strategy.
- Font and language needs, including CJK or multilingual support.
- Math strategy: numbering, theorem-like environments, symbol cleanup, and encoded glyph handling.
- Figure, table, diagram, and crop strategy.
- Citation, bibliography, appendix, index, glossary, and generated-list strategy.
- Toolchain assumptions such as XeLaTeX, BibTeX or biblatex, makeindex or glossary tooling, and fallback choices.
- Non-goals such as exact pagination, full-page screenshot replication, or pixel-perfect tracing.

Record these decisions in `style-profile.md` and `conversion-notes.md`. If later evidence invalidates them, update the production spec before continuing final drafting.

## Reading Order

Determine reading order before writing LaTeX:

- Single column, multi-column, sidebars, footnotes, floating figures, and tables.
- Section titles and numbering.
- Front matter, main matter, back matter, chapters, parts, appendices, table of contents, list of figures, list of tables, bibliography, index, and glossary when present.
- Captions and their associated figures or tables.
- Repeated headers and footers that should usually be omitted from semantic reconstruction.
- Page numbers, watermarks, stamps, or marginalia that should be included only if meaningful.

For multi-column pages, use the rendered image to infer natural reading flow. `pdftotext -layout` can help, but often interleaves columns incorrectly.

## Codex Visual Transcription Strategy

For scanned, mixed, damaged-text, or visually complex pages:

1. Render pages at a readable resolution, usually 180 to 220 DPI; rerender hard pages at 240 to 300 DPI when small text, formulas, or tables require it.
2. Keep durable evidence under `latex/evidence/source-pages/`; use temporary files only for throwaway experiments.
3. Provide Codex the page image, optional single-page PDF, optional neighboring-page context, and optional digital text-layer excerpt only when the page is digital.
4. Zoom into hard regions such as formulas, tables, captions, and footnotes.
5. Transcribe content semantically. Preserve paragraphs, section structure, formulas, table meaning, and citations rather than line breaks or page geometry.
6. Mark uncertain words, symbols, or table cells in `conversion-notes.md` and `conversion-state.md`.
7. Store page-level transcription evidence under `transcripts/` or reference it from `conversion-notes.md`.

If a digital text-layer extract and visual reading disagree, prefer the visible page unless external evidence proves otherwise.

Do not create a compileable draft by embedding each scanned page as `\includegraphics`. If a region cannot be read well enough, add a concise placeholder or LaTeX source comment and continue with the readable semantic content.

## Long Document Batching

For long PDFs, make batching explicit before large transcription or reconstruction:

- Start with representative analysis pages: first page, one early body page, one middle body page, one final page, plus known table-heavy, formula-heavy, bibliography, appendix, index, or glossary pages when detected.
- Record a feasibility note before broad transcription: total pages, estimated scanned or complex pages, target delivery level, proposed first milestone, Goal-mode decision, active Goal status, and any fallback or blocker.
- Use 5-10 pages per batch for scanned, mixed, damaged-text, table-heavy, or formula-heavy pages.
- Use 20-50 pages per batch for mostly digital prose after page-bounded text-layer evidence exists.
- For mostly digital prose, a batch may be a text-layer correction and object review batch rather than a visual transcript batch.
- Record each batch in `page-manifest.md` with page range, route, assigned evidence paths, transcript or correction status, and unresolved objects.
- Update `conversion-state.md` after every completed batch with the latest completed pages and the next concrete batch.
- For books, batch by structural boundary when possible: front matter, each chapter or chapter section, appendices, bibliography, and index/glossary.

Do not commit to full-page transcription for a very long scanned PDF without a resumable batch plan, a current state file, and an active Goal or a documented `goal-unavailable-fallback`/blocker.

## Profile Upgrade Checklist

Upgrade the project profile when deeper analysis shows the provisional profile is too light. Prefer `scripts/upgrade_latex_project.sh TARGET_DIR NEW_PROFILE` when available, or create the missing template files manually without overwriting existing work.

Use this checklist:

- Update `Task profile:` and profile history in `conversion-state.md` and `conversion-notes.md`.
- For `standard`, ensure `page-manifest.md`, `object-inventory.md`, `style-profile.md`, and `document-ir.md` exist.
- For `book`, ensure standard tracking files exist and add `frontmatter/` and `backmatter/` when useful.
- For `math-heavy`, ensure standard tracking files plus `math-inventory.md` and `glyph-map.md` exist.
- For `book-math`, ensure both book and math additions exist.
- Record why the upgrade was needed and what analysis or reconstruction action comes next.

## Page Manifest

Create `page-manifest.md` before large-scale transcription. Keep it compact and update it as pages are rendered, sampled, assigned, transcribed, merged, or revisited. For new projects, start from `assets/templates/page-manifest.md` or `scripts/init_latex_project.sh`. For long PDFs, include a rendering plan so future batches do not duplicate existing page evidence.

Use this shape:

```text
# Page Manifest

Source PDF:
Rendered pages: evidence/source-pages/
Single-page PDFs:
Digital text-layer extracts:
Batch plan:
Task profile:
Rendering plan:

## Page Routes
- page: 001
  region: full page
  route: digital
  evidence: evidence/source-pages/page-001.png
  text layer: evidence/text-layer/page-001.txt
  batch: 001
  target: chapters/01-introduction.tex
  status: pending
  unresolved:
```

For each page transcript, capture:

```text
Page:
Route:
Batch:
LaTeX fragment:
Figures:
Tables:
Equations:
Continuity:
Uncertainties:
```

When permitted by the current system and user instructions, independent page batches may be delegated to subagents. Give each subagent a bounded batch, the relevant page images, optional digital text-layer excerpts, and the required page transcript format. Subagents should return transcript fragments, object notes, math findings, or review findings only; the main agent must merge fragments, resolve cross-page continuity, update shared state files, and produce the final LaTeX project.

## Source Completeness Audit

Run this audit before large-scale reconstruction for `publication polish`, and whenever a standard project appears likely to miss source material. Its purpose is to prevent silent omissions before final LaTeX is drafted.

Use these statuses consistently in `page-manifest.md`, `object-inventory.md`, `document-ir.md`, and notes:

```text
pending | in-progress | rebuilt | reviewed | blocked | omitted-with-reason
```

Audit:

- Every source page or meaningful region has a route, evidence path when needed, batch assignment, and status.
- Every route has a reconstruction target: text-layer correction, visual transcription, asset crop, semantic table, formula rebuild, bibliography/index handling, or documented omission.
- Every major figure, table, formula group, citation block, front/back-matter item, appendix, glossary/index item, cross-reference, and unresolved visual region appears in `object-inventory.md` or a documented light-profile replacement.
- `document-ir.md` contains or references the blocks needed to cover the routed pages and high-value objects.
- All `blocked` items name the source page, visual evidence, reason, and concrete user-facing question or next action.
- All `omitted-with-reason` items state why omission is acceptable for the selected delivery level.
- For math-heavy or encoded PDFs, `math-inventory.md` and `glyph-map.md` contain the high-risk equations and recurring symbol groups discovered so far.

Record the audit result in `conversion-notes.md` and update `conversion-state.md`. Do not start broad final drafting for `publication polish` while pages or major objects are unclassified.

## Object Inventory

Create `object-inventory.md` before final LaTeX generation. Treat it as the checklist for high-value content that should not get lost during page merging.

Use this shape:

```text
# Object Inventory

Figures:
- id:
  source pages:
  caption:
  target:
  asset/crop needed:
  status:
  unresolved:

Tables:
- id:
  source pages:
  caption:
  structure:
  target:
  status:
  unresolved:

Book structure:
- front matter:
- main matter:
- back matter:
- table of contents/list pages:
- appendix pages:
- index/glossary pages:

Equations:
- id or number:
  source pages:
  surrounding text:
  visual evidence:
  target:
  confidence:
  status:
  unresolved:

Math artifacts:
- marker or pattern:
  source pages:
  likely symbol:
  status:

References and citations:
- citation style:
- bibliography pages:
- unresolved citations:

Cross-references:
- label or visible reference:
  source pages:
  target object:
  status:

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
Document profile: article | academic paper | report | book | textbook | monograph | proceedings | book chapter | thesis | dissertation | manual | handout | form | math-heavy | table-heavy | CJK/multilingual | other
Document class:
Language and font needs:
Sectioning depth:
Bibliography strategy:
Figure strategy:
Table strategy:
Math strategy:
Book production strategy:
Layout notes:
Packages likely needed:
Packages to avoid unless necessary:
```

Use the profile to decide whether the baseline should stay minimal or add focused support such as `book`, `report`, `ctexbook`, `xeCJK`, `tabularx`, `longtable`, `siunitx`, `biblatex`, `multicol`, landscape pages, generated lists, indexing, glossary support, or theorem environments. If a package may be missing, prefer a portable fallback and record the decision.

## Book Production Signals

For book-scale documents, read `references/book-production.md` and record:

- Front matter pages: title, copyright, dedication, foreword, preface, acknowledgements, table of contents, list of figures, list of tables, notation list.
- Main matter hierarchy: parts, chapters, sections, exercises, theorem-like blocks, and chapter-scoped numbering.
- Back matter pages: appendices, bibliography/references, glossary, index, colophon, or edition notes.
- Cross-reference patterns for chapters, equations, figures, tables, appendices, theorem-like blocks, citations, and page references.

Do not force this path for a short paper with only ordinary sections and references.

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
- Detect recurring encoded glyphs, raw symbol markers, placeholder display blocks, missing relation symbols, and formulas that `pdftotext` flattens into prose.
- For many formulas or any custom encoded glyph pattern, create `math-inventory.md` and `glyph-map.md`; record source pages, visible symbol evidence, LaTeX replacements, confidence, and review status.
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
Rendered batches:
Optional digital text-layer extracts:
Object inventory:
Style profile:
Task profile:
Structure:
Figures:
Tables:
Formulas:
Math artifacts:
References:
Book structure:
Cross-references:
Uncertainties:
External sources used:
```

This map can live in `conversion-notes.md` and evolve during reconstruction.

For resumability, keep `conversion-state.md` shorter and action-oriented:

```text
Current phase: analysis complete
Completed checkpoints:
- Initial triage complete
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
