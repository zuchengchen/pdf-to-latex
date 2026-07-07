# Book Production Reference

Use this reference when the PDF is a book, textbook, technical monograph, proceedings volume, thesis, dissertation, long academic manual, or when it contains book-specific structures such as preface, table of contents, list of figures, list of tables, appendices, bibliography, glossary, or index.

Do not load this path for a short article merely because it has sections, figures, or references. The goal is publication-grade long-document reconstruction without making simple conversions heavier.

## Contents

- Book Signals
- Book IR
- LaTeX Strategy
- Front Matter
- Main Matter
- Figures, Tables, And Formulas
- Back Matter
- Index And Glossary
- Cross-Reference Audit
- Refinement Passes
- Quality Gates

## Book Signals

Treat a document as book-scale when several of these are present:

- Parts, chapters, lessons, or numbered chapter-level sections.
- Front matter such as half title, title page, copyright page, dedication, foreword, preface, acknowledgements, abstract, table of contents, list of figures, list of tables, or notation list.
- Back matter such as appendices, bibliography, references, glossary, index, author biography, colophon, or edition notes.
- Chapter-scoped numbering for equations, figures, tables, examples, exercises, theorems, definitions, or algorithms.
- Repeated running heads, recto/verso page style, Roman numeral front matter pages, or a clear transition from front matter to main matter.
- Long cross-reference chains such as "see Chapter 4", "Equation (3.2)", "Figure 7.5", "Appendix B", or "Table 2.1".

Record the decision in `style-profile.md`:

```text
Task profile: book | book-math
Book production: yes | no | partial
Book type: textbook | monograph | proceedings | thesis | dissertation | technical manual | other
Front matter present:
Main matter structure:
Back matter present:
Numbering style:
Index/glossary present:
Book reference loaded: yes
```

## Book IR

Extend `document-ir.md` with book-level structure before writing final LaTeX:

```text
Book model:
  document class target:
  front matter:
  main matter:
  back matter:
  numbering policy:
  cross-reference policy:

Front matter:
- type: half-title | title-page | copyright | dedication | foreword | preface | acknowledgements | abstract | toc | lof | lot | notation
  source pages:
  target file:
  status:

Main matter:
- type: part | chapter | section | subsection | theorem | definition | example | exercise | paragraph | equation | figure | table | note
  number:
  title:
  source pages:
  target file:
  labels:
  status:

Back matter:
- type: appendix | bibliography | references | glossary | index | colophon | note
  source pages:
  target file:
  status:

Cross-reference audit:
Unresolved book objects:
```

Use this IR to decide file boundaries. For long books, prefer stable files such as `frontmatter/preface.tex`, `chapters/03-methods.tex`, and `backmatter/appendix-a.tex` when that improves maintainability. The scaffold helper creates `frontmatter/` and `backmatter/` for `book` and `book-math` profiles; add them manually if a project was initially scaffolded as `standard` and later upgraded. For shorter theses or manuals, `chapters/` plus clear comments may be enough. Explain simplifications in `conversion-notes.md`.

## LaTeX Strategy

Choose the class and packages from the document profile, not from a desire to mimic every page:

- Use `book` for ordinary books and monographs when no stronger class is needed.
- Use `report` for thesis-like or technical report structures that do not need true book front/back matter.
- Use a user-provided or institution-specific thesis class only when it already exists in the project or the user supplies it.
- Use CJK-capable classes or packages, such as `ctexbook` or `xeCJK`, only when the language and local TeX installation support them.
- Consider `memoir` or KOMA-Script only when already present or clearly helpful and available; prefer portable defaults when uncertain.
- Use `amsmath`, `amssymb`, and theorem packages only when the document actually needs them.
- Use `makeidx`, `imakeidx`, `glossaries`, `biblatex`, or BibTeX only when needed and supported by the local toolchain; otherwise use simpler semantic fallbacks and record the limitation.

For book-class projects, use normal matter switches where appropriate:

```tex
\frontmatter
\tableofcontents
\listoffigures
\listoftables

\mainmatter
\input{chapters/01-introduction}

\appendix
\input{backmatter/appendix-a}

\backmatter
\printbibliography
\printindex
```

Do not emit commands such as `\printindex`, `\printglossary`, or `\printbibliography` unless the corresponding package, data, and compilation path are present or a documented fallback exists.

## Front Matter

Reconstruct visible front matter semantically:

- Title page, subtitle, authors, editors, affiliations, publisher, edition, date, and series information.
- Copyright, ISBN, license, edition, printing, or publisher notes when visible.
- Dedication, epigraph, foreword, preface, acknowledgements, abstract, and notation list.
- Table of contents, list of figures, and list of tables.

Use generated `\tableofcontents`, `\listoffigures`, and `\listoftables` when the rebuilt structure and captions support them. Preserve source TOC text in notes only when generated lists cannot yet be trusted. Do not hand-type a static TOC as final output unless the user explicitly requests source-page reproduction.

For front matter with Roman numbering in the source, use `\frontmatter` or an equivalent numbering policy when the chosen class supports it. Record any divergence from source page numbering in `conversion-notes.md`.

## Main Matter

Rebuild the main text as a book, not as one flat article:

- Preserve parts, chapters, sections, subsections, exercises, examples, theorem-like blocks, and chapter summaries.
- Use semantic environments for theorem-like content when repeated structures are visible: `theorem`, `definition`, `lemma`, `proposition`, `corollary`, `example`, `exercise`, `proof`, or project-specific names.
- Preserve chapter-scoped numbering when visible, such as Equation (2.3), Figure 4.1, Table 5.2, or Theorem 1.4.
- Keep labels stable and descriptive, for example `chap:introduction`, `sec:fourier-transform`, `fig:phase-portrait`, `tab:error-rates`, `eq:wave-equation`, `thm:existence`.
- Convert repeated running headers, page numbers, and decorative dividers into page-style decisions only when useful; do not leave them in body text.
- Preserve footnotes and endnotes when meaningful. Convert marginal notes or sidebars into semantic notes only when they carry content.

For proceedings volumes, preserve editor-level front matter and per-paper chapter boundaries. Treat each paper chapter like a local article inside the volume, with its own title, authors, abstract, references, and appendices when visible.

## Figures, Tables, And Formulas

Use the normal figure, table, and math guidance from `latex-rebuild.md` and `math-polish.md`, with book-specific checks:

- Preserve chapter-scoped figure, table, theorem, and equation numbering when visible.
- Make captions sufficient for generated lists of figures and tables.
- Use `\label` and `\ref` consistently for objects that are referenced in the text.
- For long tables, consider `longtable`, `tabularx`, landscape pages, or appendix placement only when the source structure calls for it.
- For formula-heavy books, keep `math-inventory.md` organized by chapter and source page.
- For notation lists, preserve symbol, meaning, units, and first-use context when visible.

Do not let a generated TOC, list of figures, or list of tables become the only proof that objects exist. Reconcile them against `object-inventory.md` and the rendered PDF.

## Back Matter

Reconstruct back matter according to the source:

- Appendices should use `\appendix` or equivalent class support, preserve appendix letters/numbers, and keep appendix figures, tables, formulas, and references coherent.
- Bibliography or references should preserve the source citation style where practical. Use `references.bib`, `biblatex`, BibTeX, or `thebibliography` according to document size and local tool support.
- For per-chapter bibliographies, keep the chapter association clear and avoid flattening them into one list unless the user asks.
- Glossary and notation lists should be semantic lists or glossary tooling when tool support is available.
- Index pages should be reconstructed or prepared only when visible in the source or explicitly requested. Do not invent index terms.

For bibliography cleanup, public web lookup may be used for DOI, arXiv, title, author, venue, or BibTeX metadata only when it improves accuracy. Record which metadata came from the PDF and which came from public sources.

## Index And Glossary

When an index is present:

- Record index pages in `object-inventory.md` and `document-ir.md`.
- Preserve visible index headings, terms, subterms, and page-reference style when reconstructing an index page manually.
- If using generated indexing, add `\index{...}` entries only for terms visible in the source index or explicitly requested by the user.
- Compile with the required indexing step only when the local toolchain supports it; otherwise keep a semantic manual index and document the limitation.
- Verify that the final output does not contain `\printindex` without generated index content.

When a glossary or notation list is present:

- Preserve term, definition, symbol, unit, and first-use context when visible.
- Use glossary tooling only when supported and useful; otherwise use a semantic `description`, `longtable`, or chapter-level notation section.
- Do not silently merge glossary, notation, and index content unless the source does so.

## Cross-Reference Audit

Before delivery, audit book-level references:

- Chapters, sections, appendices, figures, tables, equations, theorems, exercises, examples, bibliography entries, footnotes, and index/glossary entries.
- Source references such as "see page", "see above", "later in this chapter", or "the next section" that may be wrong after repagination.
- Undefined `\ref`, `\pageref`, `\eqref`, `\cite`, and generated-list warnings in LaTeX logs.
- Duplicate labels and stale labels left from generated drafts.
- Captions missing labels when the text refers to the object.
- Appendix numbering, equation numbering, and theorem numbering after `\appendix`.

Fix references when the source intent is clear. If source page references cannot be preserved after semantic repagination, document the change and prefer structural references such as chapter, section, figure, table, or equation.

## Refinement Passes

For book-scale documents, add these passes to the normal refinement loop:

1. **Book Structure Pass**: confirm front matter, main matter, and back matter boundaries; replace flat sections with parts, chapters, appendices, and generated lists where appropriate.
2. **Numbering Pass**: reconcile chapter, equation, figure, table, theorem, appendix, and bibliography numbering against the source.
3. **Cross-Reference Pass**: fix labels, references, citations, generated lists, and source page-reference wording.
4. **Back Matter Pass**: reconcile appendices, bibliography, glossary, and index against the source PDF and inventories.
5. **Long-Document Typography Pass**: review chapter openings, page breaks, large floats, long tables, running heads when used, and severe overfull boxes.

For long books, sample every structural area rather than only early pages: front matter, an early chapter, a middle chapter, a formula-heavy page, a table-heavy page, appendices, bibliography, and index/glossary pages when present.

## Quality Gates

Do not call a book-scale reconstruction publication-grade until:

- `style-profile.md` records the book profile and chosen class strategy.
- `document-ir.md` includes front matter, main matter, back matter, numbering policy, and cross-reference policy when present in the source.
- Generated or reconstructed table of contents, list of figures, and list of tables are consistent with final headings and captions when they are present or requested.
- Major figures, formulas, tables, theorem-like blocks, appendices, bibliography entries, and index/glossary items are rebuilt, reviewed, or explicitly documented as unresolved.
- LaTeX logs have no unresolved references or citations that affect delivered content.
- Book-specific refinement passes are complete or marked not applicable with a reason.
- The rendered PDF is readable across sampled front matter, normal chapters, dense object pages, appendices, bibliography, and index/glossary pages.
- The final source remains maintainable: book structure is semantic, labels are meaningful, and long content is split into files when that helps future editing.
