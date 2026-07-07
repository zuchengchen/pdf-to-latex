# Goal Mode Reference

Use this reference when a PDF-to-LaTeX conversion should run as a goal-backed task.

## When To Use Goal Mode

Use goal-backed execution for full conversion requests such as:

```text
$pdf-to-latex 把 "Quantum Field Theory for the Gifted Amateur.pdf" 转成latex
```

This is the default intent for complete PDF rebuilding because the work may require page rendering, visual transcription, document modeling, LaTeX generation, compilation, polishing, and quality review over multiple continuations.

Do not force goal mode for narrow requests such as explaining this skill, reviewing an existing LaTeX snippet, fixing one compile error, or producing a rough draft when the user explicitly asks for one.

## Goal Startup

Before creating a goal:

1. Confirm the source PDF path and target directory.
2. Inspect the target directory only enough to know whether this is a new conversion or a resumable one.
3. Check the active goal state when goal tools are available.
4. Continue a matching active goal instead of creating a duplicate.
5. Ask the user if an active goal conflicts with the requested PDF conversion.

If runtime policy requires the user to explicitly authorize goal creation, ask one short yes/no confirmation and proceed after confirmation. Otherwise create the goal directly.

## Objective Template

Use a concrete objective like this, filling in paths:

```text
Use $pdf-to-latex to rebuild SOURCE_PDF into an editable XeLaTeX project under TARGET_DIR. Continue from TARGET_DIR/conversion-state.md on every turn when it exists. Complete only when page evidence and page-manifest.md exist, page transcripts are completed or uncertainties are documented, object-inventory.md, style-profile.md, and document-ir.md exist, main.tex and chapter files are generated from document-ir.md, the project compiles successfully with XeLaTeX, minimum refinement passes and reviewer checks are completed, quality-review.md checks pass or remaining issues are explicitly documented, conversion-notes.md records verification, and conversion-state.md says Next action: None; quality review complete.
```

Do not include a token budget unless the user explicitly requested one.

## Goal State Files

Create `goal-objective.md` in the target LaTeX directory when useful for restart clarity. Keep it concise:

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
- `page-manifest.md` exists when page-level transcription was used.
- `object-inventory.md`, `style-profile.md`, and `document-ir.md` exist when page-level reconstruction was used, or their omission is justified for a small/simple document.
- Final LaTeX is generated from the document IR rather than raw page transcript stitching.
- The latest XeLaTeX or `latexmk -xelatex` compile succeeds.
- The minimum refinement passes in `latex-refinement.md` are complete or documented as not applicable.
- Reviewer findings and the quality rubric are addressed or documented.
- Visual and text checks from `quality-review.md` pass.
- `conversion-notes.md` lists commands, verification, approximations, and unresolved issues.
- `conversion-state.md` has `Next action: None; quality review complete`.

## Stop Conditions

Stop and ask the user when:

- The PDF path is missing or ambiguous.
- The target directory exists but has no recoverable state and proceeding may overwrite user work.
- A required verification tool is missing and no acceptable fallback exists.
- The source pages are unreadable enough that Codex cannot make a reasonable semantic reconstruction.
- The user requests local OCR, cloud OCR, a bundled converter, or pixel-perfect replication that conflicts with this skill's purpose.
- A conflicting active goal exists and the user has not chosen which goal to pursue.

## Continuation Behavior

On every continuation:

1. Read `conversion-state.md` first.
2. Verify active files named in the state file still exist.
3. Open only the notes, logs, transcripts, IR, or source files needed for the next action.
4. Do the next concrete milestone.
5. Update `conversion-state.md` and `conversion-notes.md` before yielding.

Do not mark the goal complete merely because a PDF compiled once. The first successful compile is a checkpoint.
