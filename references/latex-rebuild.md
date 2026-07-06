# LaTeX Rebuild Reference

Use this reference when creating the target LaTeX project. The project should be editable, semantic, and easy for a user or future Codex agent to refine.

## Reconstruction Principles

- Rebuild meaning and document structure before visual details.
- Use normal LaTeX sectioning, lists, tables, figures, equations, and bibliography tools.
- Preserve the PDF's logical order, terminology, labels, captions, references, and important formatting.
- Avoid absolute positioning, page-by-page overlays, and screenshot-only pages unless the user explicitly requests visual recreation.
- Mark inferred or approximate content in source comments and in `conversion-notes.md`.

## Project Layout

Default layout:

```text
latex/
├── main.tex
├── chapters/
│   ├── 01-introduction.tex
│   └── ...
├── figures/
├── tables/
└── conversion-notes.md
```

Small documents may keep all content in `main.tex`, but still include `conversion-notes.md` unless the user explicitly says otherwise.

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

For CJK or multilingual content, add appropriate XeLaTeX packages such as `xeCJK` when available in the local TeX installation. Use `\IfFontExistsTF` or a simpler default when a preferred font may be missing. If a package is missing, choose a simpler fallback or ask before installing system packages.

## Structure

Build a semantic outline first:

- Title, subtitle, authors, affiliations, date, abstract.
- Sections and subsections.
- Body paragraphs in reading order.
- Lists, quotations, callouts, appendices, and footnotes.
- Figures and tables close to their first reference.
- Equations with numbering when meaningful.
- Bibliography or references.

Do not preserve repeated page headers, footers, or page numbers unless they carry content.

## Text

Normalize extracted text into readable LaTeX:

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

For large tables, consider `longtable`, landscape pages, or smaller font sizes only when needed. Mark uncertain cells with comments, not silent substitutions.

## Formulas

Use standard LaTeX math:

```tex
\begin{equation}
  E = mc^2
\end{equation}
```

Preserve equation numbering when the source uses it. For uncertain symbols, add a local comment and a note:

```tex
\begin{equation}
  f(x) = \alpha x + \beta
\end{equation}
% Uncertain: the scan makes beta difficult to distinguish from gamma.
```

Use web lookup for standard formulas only when it improves accuracy, and record the source.

## Citations And References

Choose the simplest approach that matches the document:

- For short documents, a manual `thebibliography` block is acceptable.
- For academic papers or many references, create `references.bib` and use `biblatex` or BibTeX only if the local toolchain supports it.
- Preserve citation keys consistently, for example `\cite{smith2024method}`.

Label metadata added from public web sources in `conversion-notes.md`.

## Conversion Notes

Always maintain `conversion-notes.md` with:

- Source PDF path and conversion date.
- Tools and commands used.
- PDF type and analysis summary.
- Inferred, approximated, or web-sourced content.
- Missing or unclear regions.
- Compile command and review status.
- Suggested manual follow-up.

Keep notes factual and actionable. They are part of the deliverable.
