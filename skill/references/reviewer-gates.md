# Reviewer Gates Reference

Use this reference when `publication polish` requires midpoint or final reviewer gates, or when a project needs an independent structured review pass. Reviewer gates should produce concrete findings only; the main agent owns edits, merges, compilation, notes, state, and final quality decisions.

## Contents

- Reviewer Principles
- Output Format
- Midpoint Reviewer Gate
- Final Structure/Content Reviewer
- Final Math/Object Reviewer
- Final Build/Layout Reviewer
- Pass And Blocker Rules

## Reviewer Principles

- Review against the recorded delivery contract, source evidence, production spec, source completeness audit, document IR, object inventory, and rendered rebuilt output when available.
- Report actionable defects, not vague impressions.
- Separate blocking issues from non-blocking cleanup.
- Do not rewrite source files as part of the review pass unless the main workflow explicitly assigns that work.
- Do not mark a gate passed while required evidence is missing.

## Output Format

Use this format for every reviewer gate:

```text
Gate:
Scope reviewed:
Evidence used:
Result: pass | blocked
Blocking issues:
- id:
  location:
  evidence:
  required next action:
Non-blocking issues:
- id:
  location:
  evidence:
  suggested action:
Approximations accepted:
Follow-up checks:
```

If there are no blocking or non-blocking issues, write `none` under the matching heading. Record the completed review in `conversion-notes.md` and update `conversion-state.md`.

## Midpoint Reviewer Gate

Run this after delivery contract, production spec, page routes, inventories, source completeness audit, skeleton compile, and asset discovery are ready, but before most final content is drafted.

Check:

- The delivery contract is compatible with the evidence and planned tooling.
- Page and region routes cover the visible source.
- `object-inventory.md` and `document-ir.md` own all major figures, tables, formulas, citations, front/back matter, appendices, glossary/index items, and unresolved visual regions.
- The selected document class, file structure, packages, fonts, bibliography/index/glossary strategy, and math strategy are plausible and have compiled as a skeleton.
- Blocked items have user-facing questions before broad drafting continues.

The midpoint gate passes only when plan-level gaps are fixed or localized blockers are documented.

## Final Structure/Content Reviewer

Check:

- Reading order, section hierarchy, title/author/abstract, and cross-page merges.
- Missing, duplicated, or reordered content.
- Book front matter, main matter, back matter, generated lists, appendices, bibliography, glossary, and index when present.
- Final LaTeX alignment with `document-ir.md`, page manifest, and source completeness audit.
- Raw transcript boundaries, repeated headers/footers/page numbers, artificial page breaks, or page screenshots that should be semantic content.

## Final Math/Object Reviewer

Check when math, tables, figures, citations, or object-heavy content is present:

- Major equations, theorem-like blocks, notation lists, and equation references.
- `math-inventory.md` and `glyph-map.md` reconciliation when present.
- Absence of `\pdfglyph`, `extracteddisplay`, raw encoded math, and formula placeholders in final included source.
- Tables are semantic LaTeX when legible; captions, labels, and references are coherent.
- Figures, diagrams, crops, captions, labels, and figure references match the object inventory.
- Citations and bibliography entries are complete enough for the selected delivery level.

Use `Result: pass` only when missing or uncertain objects are localized and documented.

## Final Build/Layout Reviewer

Check:

- Latest compile and clean-room build status.
- Missing files, undefined commands, unresolved references or citations, rerun warnings, bad fonts, and package errors.
- Severe overfull boxes, clipping, blank pages, unreadable tables, oversized or undersized figures, awkward float placement, and obvious typography defects.
- Rendered rebuilt pages are nonblank and readable; high-risk source pages from the completeness audit were visually compared.
- `scripts/publication_gate.sh PROJECT_DIR main.tex --strict-findings` and `scripts/check_workflow_gates.sh PROJECT_DIR` results when available.

## Pass And Blocker Rules

Use `Result: blocked` when a required source page, object, formula, reference, build artifact, or verification step is missing or unresolved for the selected delivery contract. Use `Result: pass` only when remaining issues are either fixed, marked not applicable, or explicitly accepted as localized approximations.

Do not downgrade publication polish to clean semantic or rough draft inside a reviewer gate. Recommend the downgrade in `required next action` and let the main agent ask the user or record the blocker according to `quality-review.md`.
