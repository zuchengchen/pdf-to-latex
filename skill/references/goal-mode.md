# Goal Mode Reference

Use this reference when Mandatory Goal Mode Planning is required for a PDF-to-LaTeX conversion, reconstruction, broad refinement, or quality-review task.

## Goal Enablement Planning

Classify the request before scaffolding a new conversion, resuming broad reconstruction, or starting major refinement or quality review:

- `goal-required`: any full PDF-to-LaTeX conversion or rebuild; any existing PDF-derived LaTeX project needing broad refinement or quality review; any `publication polish` task; any long, scanned, mixed, math-heavy, encoded, book-scale, or multi-batch task. A light-profile full conversion is still `goal-required` when the user expects a completed LaTeX project rather than a one-shot rough draft.
- `goal-skipped`: only for explaining this skill, initial triage with no reconstruction, reviewing a snippet, fixing one localized compile or layout issue, or a user-requested rough draft, one-shot partial pass, or narrow repair that can be completed in the current turn.
- `goal-unavailable-fallback`: the task is `goal-required`, but goal tools are unavailable or current runtime policy forbids goal creation. Continue with the same resumable state-file workflow, record the limitation, and do not lower the delivery level merely because Goal mode is unavailable.

Record the decision, reason, active Goal status, and any fallback in `conversion-state.md` and `conversion-notes.md`.

## When To Use Goal Mode

Use goal-backed execution for full conversion requests such as:

```text
$pdf-to-latex 把 "Quantum Field Theory for the Gifted Amateur.pdf" 转成latex
```

Goal mode is mandatory for `goal-required` tasks when goal tools are available and runtime policy allows goal creation because PDF-to-LaTeX work may require page rendering, visual transcription, document modeling, LaTeX generation, math publication polish, compilation, polishing, and quality review over multiple continuations.

Do not create a Goal for `goal-skipped` tasks. If a quick initial pass shows that the user asked only for explanation, triage, a single localized repair, or an explicit rough draft, record the skip reason and keep the normal state-file workflow as needed.

## Goal Startup

Before creating a goal:

1. Confirm the source PDF path and target directory.
2. Inspect the target directory only enough to know whether this is a new conversion or a resumable one.
3. Check the active goal state when goal tools are available.
4. Continue a matching active goal instead of creating a duplicate.
5. Ask the user if an active goal conflicts with the requested PDF conversion.
6. Confirm that the request is `goal-required`.
7. If the current runtime requires explicit user approval and the user has not already requested Goal mode, ask for the shortest yes/no confirmation before calling a goal tool.

Only call goal tools when they are available in the current runtime and policy allows them. If approval is required but missing, ask one short yes/no confirmation and proceed only after confirmation. If the user declines Goal mode for a `goal-required` full conversion, do not proceed as a normal full conversion; ask whether to reduce scope to rough draft, triage, or a narrow repair, or record a blocker. If goal tools are unavailable or policy forbids goal creation, use `goal-unavailable-fallback` and continue with the same resumable conversion workflow through `conversion-state.md` and `conversion-notes.md`; do not treat the task as a rough draft merely because Goal mode is unavailable.

## Objective Template

Use a concrete objective like this, filling in paths:

```text
Use $pdf-to-latex to rebuild SOURCE_PDF into an editable XeLaTeX project under TARGET_DIR at DELIVERY_LEVEL. Continue from TARGET_DIR/conversion-state.md on every turn when it exists. Complete only when Goal-mode planning is recorded, initial triage is complete, the exact task profile (`light`, `standard`, `book`, `math-heavy`, or `book-math`) and delivery level are recorded, any profile upgrade is documented, the delivery contract and production spec gates are complete for publication polish, durable page evidence exists under TARGET_DIR/evidence/source-pages when visual transcription or comparison is needed, page-bounded text-layer evidence exists under TARGET_DIR/evidence/text-layer when digital extraction is used, page-manifest.md records any long-document batch plan and page or region routes, source completeness audit reconciles required pages/regions/objects for publication polish, page-manifest.md and page transcripts exist when the selected profile requires them, object-inventory.md, style-profile.md, and document-ir.md exist or their light-profile omission is documented, book-production checks are completed when the document is a book, thesis, monograph, proceedings volume, or has front/back matter, math-inventory.md and glyph-map.md exist when the document is math-heavy or encoded, the skeleton compile gate and asset discovery gate have passed before broad final drafting for publication polish, the midpoint reviewer gate is complete for publication polish, main.tex and chapter files are generated from document-ir.md or a documented light-profile outline, high-risk batches compile before moving on, assets and bibliography/index/glossary inputs are present or documented as unresolved, the project compiles successfully with XeLaTeX, minimum refinement passes and final reviewer gates are completed according to DELIVERY_LEVEL, math artifact scans of final source are clean when applicable, the clean-room build gate and workflow gate check pass for publication polish, quality-review.md checks pass or true blockers are documented, conversion-notes.md records verification, and conversion-state.md says Next action: None; quality review complete.
```

Do not include a token budget unless the user explicitly requested one.

## Goal State Files

Create `goal-objective.md` in the target LaTeX directory when useful for restart clarity. Start from `assets/templates/goal-objective.md` when available, or keep it concise:

```text
# Goal Objective

Source PDF:
Target directory:
Goal created:
Completion criteria:
Stop conditions:
Verification:
```

This file complements `conversion-state.md`; it should not replace the state file.

## Completion Criteria

The goal is complete only when:

- `conversion-state.md` exists and is consistent with the filesystem.
- The Goal-mode decision is recorded as `goal-required`, `goal-skipped`, or `goal-unavailable-fallback`; `goal-required` work has an active or continued Goal when goal tools are available, and fallback work records why Goal mode could not be used.
- The selected task profile is recorded in `conversion-state.md` or `conversion-notes.md`.
- Initial triage is complete, and the selected task profile is one of `light`, `standard`, `book`, `math-heavy`, or `book-math`.
- The selected delivery level is recorded, and any rough-draft shortcuts or light-profile omissions are explicitly documented.
- Any profile upgrade, such as `standard` to `book-math`, is documented.
- For publication polish, `conversion-notes.md` records the delivery contract, and `style-profile.md` plus `conversion-notes.md` record the production spec.
- Durable evidence exists under `evidence/source-pages/` when page-level visual transcription or later comparison was needed.
- Page-bounded text-layer evidence exists under `evidence/text-layer/` when digital extraction was used.
- Long-document batch plans and completed ranges are recorded in `page-manifest.md` when batching was needed.
- `page-manifest.md` exists when page-level transcription was used and the selected profile requires it.
- For publication polish, source completeness audit covers required pages, regions, major objects, IR blocks, and localized blockers or omissions.
- `object-inventory.md`, `style-profile.md`, and `document-ir.md` exist when page-level reconstruction was used, or their omission is justified for a light-profile task.
- For book-scale documents, `references/book-production.md` guidance has been applied and front matter, main matter, back matter, generated lists, appendices, bibliography, index/glossary when present, and cross-references are rebuilt, reviewed, or documented as unresolved.
- `math-inventory.md` and `glyph-map.md` exist and are reconciled when the document is math-heavy, encoded, or previously contained glyph/display placeholders.
- The skeleton compile gate, asset discovery gate, and midpoint reviewer gate passed before broad final drafting when publication polish was selected.
- Final LaTeX is generated from the document IR rather than raw page transcript stitching.
- Chapter, section, or high-risk object batches compiled before the final broad polish.
- The latest XeLaTeX or `latexmk -xelatex` compile succeeds.
- The minimum refinement passes in `latex-refinement.md` are complete or documented as not applicable.
- Publication-polish final reviewer gates for structure/content, math/object, and build/layout are complete when applicable.
- The clean-room build gate passes for publication polish or a true blocker is documented.
- The workflow gate check passes for publication polish or a true blocker is documented.
- For math-heavy or encoded documents, `references/math-polish.md` acceptance checks pass: final source contains no `\pdfglyph`, `extracteddisplay`, raw encoded math, or formula placeholders unless the user explicitly approved a rough draft or specific unresolved item.
- Reviewer findings and the quality rubric are addressed or documented.
- Visual and text checks from `quality-review.md` pass.
- `conversion-notes.md` lists commands, verification, approximations, and unresolved issues.
- `conversion-state.md` has `Next action: None; quality review complete`.

## Stop Conditions

Stop and ask the user when:

- The PDF path is missing or ambiguous.
- The target directory exists but has no recoverable state and proceeding may overwrite user work.
- A required verification tool is missing and no acceptable fallback exists.
- Goal mode is required, the runtime requires explicit approval, and the user declines or has not answered.
- The source pages are unreadable enough that Codex cannot make a reasonable semantic reconstruction.
- Formula symbols remain unreadable after visual review and available context, and leaving them unresolved would prevent near-publication delivery.
- The user requests local OCR, cloud OCR, a bundled converter, or pixel-perfect replication that conflicts with this skill's purpose.
- A conflicting active goal exists and the user has not chosen which goal to pursue.

## Continuation Behavior

On every continuation:

1. Read `conversion-state.md` first.
2. Verify active files named in the state file still exist.
3. Open only the notes, logs, transcripts, IR, or source files needed for the next action.
4. Do the next concrete milestone.
5. Update `conversion-state.md` and `conversion-notes.md` before yielding.

Do not mark the goal complete merely because a PDF compiled once. The first successful compile is a checkpoint, and a compiled project with broad unresolved math artifacts is still in refinement.
