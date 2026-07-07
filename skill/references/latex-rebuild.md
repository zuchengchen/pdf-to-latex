# LaTeX Rebuild Reference

Use this reference when creating the target LaTeX project. The project should be editable, semantic, and easy for a user or future Codex agent to refine.

## Contents

- Reconstruction Principles
- Project Layout
- Document Model First
- XeLaTeX Baseline
- Structure
- Text
- Figures
- Tables
- Formulas
- Citations And References
- Conversion Notes
- Conversion State

## Reconstruction Principles

- Rebuild meaning and document structure before visual details.
- Use normal LaTeX sectioning, lists, tables, figures, equations, and bibliography tools.
- Preserve the PDF's logical order, terminology, labels, captions, references, and important formatting.
- Avoid absolute positioning, page-by-page overlays, and screenshot-only pages unless the user explicitly requests visual recreation.
- For scanned or visually complex PDFs, do not make a compiling draft by embedding full-page screenshots. Use Codex visual transcription to create semantic text, math, tables, and figure assets instead.
- For digital PDFs, treat `pdftotext` output as optional text-layer evidence only; visual review still controls reading order and correction.
- For math-heavy or encoded PDFs, do not treat custom glyph placeholders or display-math wrappers as final LaTeX. Plan a math cleanup path with `math-inventory.md` and `glyph-map.md`.
- Mark inferred or approximate content in source comments and in `conversion-notes.md`.

## Project Layout

Maximum layout:

```text
latex/
├── main.tex
├── chapters/
│   ├── 01-introduction.tex
│   └── ...
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
├── conversion-state.md
└── conversion-notes.md
```

This layout is profile-dependent. Use the task profile matrix in `SKILL.md` as the canonical required-file contract, and use this reference only for rebuild-specific layout choices. Small or narrow tasks may keep all content in `main.tex`, but still include `conversion-state.md` and `conversion-notes.md` unless the user explicitly says otherwise. For light-profile tasks, omit `transcripts/`, `page-manifest.md`, `object-inventory.md`, `style-profile.md`, or `document-ir.md` only when they would add no review or resume value, and record the simplification. In that case, put a concise outline, object list, and style decision summary in `conversion-notes.md` before drafting. Keep `evidence/source-pages/` when visual transcription or later comparison is needed. Keep page-bounded `pdftotext` evidence under `evidence/text-layer/` when digital extraction is used; prefer `scripts/extract_text_pages.sh` for repeatable page-bounded extraction. Add `math-inventory.md` and `glyph-map.md` when formulas are numerous, when PDF text extraction has custom encoded symbols, or when generated source contains math placeholders.

For new projects, prefer `scripts/init_latex_project.sh SOURCE_PDF TARGET_DIR TASK_PROFILE DELIVERY_LEVEL` or the files in `assets/templates/` to create the scaffold. Use the exact task profile and delivery level values from `SKILL.md`. The helper creates initial state files without overwriting existing files; it aborts on non-PDF-looking sources and unrelated non-empty target directories. For `light`, it creates only core files plus `logs/`; for heavier profiles it creates working directories such as `chapters/`, `figures/`, `tables/`, `transcripts/`, and `evidence/`; for book profiles it creates `frontmatter/` and `backmatter/`; for math profiles it creates math tracking files. After scaffolding, replace the minimal `main.tex` with source-derived semantic content.

If later analysis requires a heavier profile, prefer `scripts/upgrade_latex_project.sh TARGET_DIR NEW_PROFILE`. It creates missing profile files from templates without replacing existing work; after running it, update profile history, the current phase, and the next action in `conversion-state.md` and `conversion-notes.md`.

For book-scale documents, read `references/book-production.md`. Add `frontmatter/`, `chapters/`, or `backmatter/` when those boundaries make the project easier to edit, and record the decision in `style-profile.md` and `conversion-notes.md`.

Before creating files in an existing project, read `conversion-state.md` and `conversion-notes.md` when present. If they indicate an interrupted conversion, resume from the recorded next action and preserve existing generated or user-edited files.

## Document Model First

Before drafting final LaTeX for standard, book, math-heavy, book-math, or visually complex projects, build `document-ir.md` from transcripts, page-bounded text-layer evidence when used, `object-inventory.md`, `style-profile.md`, math inventory when applicable, and visual review. Do not directly stitch page fragments into chapters except for very small documents where the notes explain why an IR would add no value.

Use this compact shape, or start from `assets/templates/document-ir.md`:

```text
# Document IR

Metadata:
Style profile:

Blocks:
- type: title | abstract | part | chapter | section | paragraph | list | theorem | equation | figure | table | citation | bibliography | appendix | glossary | index | note
  source pages:
  content or reference:
  label:
  confidence:

Book model:
Cross-page merges:
Objects:
Math inventory:
Unresolved blocks:
Style decisions:
```

Generate `main.tex` and `chapters/*.tex` from this document model. The IR should make page order, section hierarchy, object placement, and unresolved uncertainties explicit before final source is written. For a light task, a concise outline inside `conversion-notes.md` may replace a standalone IR when the source is short and structurally simple; compare final LaTeX against that outline during quality review.

## XeLaTeX Baseline

Use XeLaTeX by default. Start with a simple, portable preamble and add packages only when needed.

```tex
\documentclass[11pt]{article}

\usepackage{fontspec}
\usepackage{geometry}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{array}
\usepackage{amsmath,amssymb}
\usepackage{hyperref}

\geometry{margin=1in}
\IfFontExistsTF{Latin Modern Roman}{\setmainfont{Latin Modern Roman}}{}

\title{Rebuilt Document}
\author{}
\date{}

\begin{document}
\maketitle

\input{chapters/01-content}

\end{document}
```

Use `style-profile.md` to choose the document class, packages, and layout. For CJK or multilingual content, add appropriate XeLaTeX packages such as `xeCJK` when available in the local TeX installation. Use `\IfFontExistsTF` or a simpler default when a preferred font may be missing. If a package is missing, choose a simpler fallback or ask before installing system packages.

For books, theses, monographs, proceedings, or documents with front/back matter, use `references/book-production.md` before choosing between `article`, `report`, `book`, `ctexbook`, a thesis class, or another class. Do not flatten a book into an article merely because the baseline example uses `article`.

## Structure

Build a semantic outline and document IR first:

- Title, subtitle, authors, affiliations, date, abstract.
- Book front matter, main matter, and back matter when present: preface, foreword, acknowledgements, table of contents, lists of figures/tables, parts, chapters, appendices, bibliography, glossary, and index.
- Sections and subsections.
- Body paragraphs in reading order.
- Lists, quotations, callouts, theorem-like blocks, appendices, and footnotes.
- Figures and tables close to their first reference.
- Equations with numbering when meaningful.
- Bibliography or references.

Do not preserve repeated page headers, footers, or page numbers unless they carry content.

Build the outline from page transcripts, digital text-layer evidence, `object-inventory.md`, `style-profile.md`, and visual page review. Record the IR checkpoint in `conversion-state.md` before drafting large LaTeX files. Include which chapters, figures, tables, formulas, or references are already planned and what should be written next.

For book-scale documents, also include the book model, numbering policy, generated-list strategy, and cross-reference policy from `references/book-production.md`.

## Text

Normalize transcribed or extracted text into readable LaTeX:

- Fix broken line wraps and hyphenation.
- Restore paragraph boundaries.
- Escape LaTeX special characters: `#`, `$`, `%`, `&`, `_`, `{`, `}`, `~`, `^`, and backslash.
- Preserve emphasis, code, small caps, and symbols when meaningful.
- Keep source comments for uncertain reconstructions.

Example:

```tex
% Approximation: the original scan is unclear around this phrase.
The proposed method reduces reconstruction error while preserving semantic layout.
```

For scanned PDFs, treat Codex page-level visual transcription as draft evidence until it has been merged into the document structure. Correct paragraph order, remove page headers and footers, restore headings, join cross-page continuations, and mark unreadable spans with short comments instead of replacing the page with an image.

For digital PDFs, `pdftotext` output can speed transcription, but it must not bypass visual review. Repair multi-column ordering, formulas, captions, footnotes, hyphenation, ligatures, and missing spaces before writing final LaTeX.

## Figures

Place extracted or cropped images in `figures/`. Use semantic figure environments:

```tex
\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.8\linewidth]{figures/example}
  \caption{Original or reconstructed caption.}
  \label{fig:example}
\end{figure}
```

If a figure is recreated as text, TikZ, or a table, note that choice in `conversion-notes.md`.

Only include images that are actual figures, diagrams, photos, charts, or other source visual content. Do not include full-page rendered scans as figure assets merely to preserve page appearance or make compilation easy.

Use `object-inventory.md` to verify that each major figure is either included, recreated, documented as unreadable, or intentionally omitted.

## Tables

Prefer `booktabs` tables for clean semantic reconstruction:

```tex
\begin{table}[htbp]
  \centering
  \caption{Example table.}
  \label{tab:example}
  \begin{tabular}{lll}
    \toprule
    Item & Value & Note \\
    \midrule
    Alpha & 10 & Clear \\
    Beta & 20 & Inferred \\
    \bottomrule
  \end{tabular}
\end{table}
```

For numeric tables, consider `siunitx` when available and useful, but fall back to ordinary alignment if the package is unavailable or unnecessary. For wide or long tables, consider `tabularx`, `longtable`, landscape pages, or smaller font sizes only when needed. Mark uncertain cells with comments, not silent substitutions.

For scanned tables, use Codex visual transcription to rebuild legible cells as semantic LaTeX tables. If a table is partly unreadable, include the clear rows or columns, mark uncertain cells, and document the gap; do not embed a screenshot table unless the user explicitly requests visual preservation.

Do not leave legible tables as space-aligned plain text in final chapters. If table structure remains uncertain, rebuild the clear structure and record the uncertainty in both source comments and `conversion-notes.md`.

## Formulas

Use standard LaTeX math:

```tex
\begin{equation}
  E = mc^2
\end{equation}
```

Use `equation` for single display formulas, `align` or `aligned` for multi-line derivations, and inline math for short terms. Use `gather`, `multline`, `split`, or `cases` when the source structure calls for them. Preserve equation numbering when the source uses it. For uncertain symbols, add a local comment and a note:

```tex
\begin{equation}
  f(x) = \alpha x + \beta
\end{equation}
% Uncertain: the scan makes beta difficult to distinguish from gamma.
```

Do not leave legible display math as ordinary text. Do not define helper macros such as `\pdfglyph` to hide unresolved symbols in the final source; those are draft artifacts that must be resolved through visual review or documented as blockers. Convert placeholder display wrappers such as `extracteddisplay` into standard math environments before final delivery.

For math-heavy documents, create or update `math-inventory.md` and `glyph-map.md` while writing chapters. Record display equation IDs, source pages, current source files, recurring glyph decisions, confidence, and review status. Use `references/math-polish.md` for the cleanup workflow and acceptance standard.

Use web lookup for standard formulas only when it improves accuracy, and record the source.

## Citations And References

Choose the simplest approach that matches the document:

- For short documents, a manual `thebibliography` block is acceptable.
- For academic papers or many references, create `references.bib` and use `biblatex` or BibTeX only if the local toolchain supports it.
- For book-scale documents, preserve per-chapter versus global bibliography structure, appendix references, and index/glossary interactions according to `references/book-production.md`.
- Preserve citation keys consistently, for example `\cite{smith2024method}`.

Label metadata added from public web sources in `conversion-notes.md`.

## Conversion Notes

Always maintain `conversion-notes.md` with:

- Source PDF path and conversion date.
- Selected task profile and any omitted heavy artifacts.
- Tools and commands used.
- PDF type and analysis summary.
- Page manifest and page transcript status.
- Document IR, object inventory, and style profile status.
- Book production status, including front matter, main matter, back matter, generated lists, cross-reference audit, bibliography, index/glossary, and appendix handling when applicable.
- Math inventory, glyph map, artifact counts, and math review status when applicable.
- Inferred, approximated, or web-sourced content.
- Missing or unclear regions.
- Compile command and review status.
- Suggested manual follow-up.

Keep notes factual and actionable. They are part of the deliverable.

## Conversion State

Always maintain `conversion-state.md` as the compact resume file. Update it when the scaffold is created, when page evidence is rendered, when page transcripts are completed, when the object inventory, style profile, and document IR are completed, when content files are added, when assets are extracted or cropped, and when a chapter, table, figure, formula, or reference batch is completed.

Start from `assets/templates/conversion-state.md` whenever possible; it is the canonical checkpoint order. If writing the state file by hand, keep this compact shape and preserve the same milestone sequence:

```text
# Conversion State

Source PDF:
Target directory:
Last updated:
Current phase:
Task profile:
Delivery level:

## Completed Checkpoints
Project scaffold, triage, analysis, evidence, manifest, transcription, inventories/profile/IR, content drafting, compile, refinement, final quality review.

## Last Successful Command

## Active Files

## Next Action

## Blockers Or Uncertainties
```

Keep the state file brief enough that a future Codex agent can read it first, then open only the referenced notes, logs, and source files needed for the next action.
