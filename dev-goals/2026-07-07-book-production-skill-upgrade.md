# Goal: Book Production Upgrade For pdf-to-latex Skill

## Goal Mode Objective

Follow the saved goal file at `/home/czc/projects/working/pdf-to-latex/2026-07-07-book-production-skill-upgrade.md`; upgrade the current `pdf-to-latex` skill for academic/technical book production workflows, verify the skill files and metadata, and stop to ask if any listed stop condition occurs.

## Full Prompt

### Objective

Upgrade the current `/home/czc/projects/working/pdf-to-latex` skill so it explicitly supports publication-grade reconstruction and refinement of academic/technical books, textbooks, proceedings, monographs, manuals with academic structure, and theses from PDF into editable XeLaTeX projects.

The completed skill must give future Codex agents clear workflow guidance for front matter, table of contents, lists of figures/tables, chapters/parts, figures, formulas, tables, theorem-like structures, appendices, bibliography/references, index/glossary when present, cross-references, and book-level quality review.

### Context

The repo is an existing Codex skill named `pdf-to-latex`.

Current important files:

- `SKILL.md`
- `references/pdf-analysis.md`
- `references/latex-rebuild.md`
- `references/latex-refinement.md`
- `references/quality-review.md`
- `references/math-polish.md`
- `references/goal-mode.md`
- `README.md`
- `agents/openai.yaml`

The existing skill already supports semantic PDF-to-LaTeX reconstruction, page evidence, document IR, object inventory, math polish, compile/refinement loops, and quality review. The gap is that long-form book production is only implicit. Add a focused book-production path without making short papers/simple documents heavier than necessary.

### Brainstorming Direction

Use a new dedicated reference file, likely `references/book-production.md`, for book/thesis/monograph-specific guidance. Keep `SKILL.md` concise and route to this reference when the source PDF is a book, thesis, textbook, technical monograph, proceedings volume, or contains book-specific structures such as preface, table of contents, list of figures/tables, appendices, bibliography, glossary, or index.

Connect this new reference into the existing analysis, rebuild, refinement, and quality review references with small targeted edits.

Do not add bundled scripts or change the skill into a CLI/tool package.

### Discovery Summary

Answered decisions:

- Implement the improvement directly in the current repo.
- Target academic/technical books, textbooks, proceedings, monographs, and theses.
- Do not add scripts; enhance workflow/reference guidance only.
- Update `SKILL.md`, references, `README.md`, and `agents/openai.yaml`.
- Verify with skill validation, text consistency checks, and one independent forward-test or review if multi-agent tools are available.
- Save this goal file at `/home/czc/projects/working/pdf-to-latex/2026-07-07-book-production-skill-upgrade.md`.
- Only update the current repo, not any installed skill directory.

Defaults and assumptions:

- Future users are Codex agents applying `$pdf-to-latex` and humans consuming the resulting LaTeX project.
- Existing paper/short-document behavior should remain valid and lightweight.
- Book-specific guidance should trigger conditionally through reference routing.
- Security, privacy, deployment, migrations, and persistent runtime state are not applicable because this task only edits skill documentation/metadata.
- If `index` or `glossary` is not visible in the source PDF, the skill should not invent one; it should reconstruct or prepare them when present or explicitly requested.
- LaTeX class guidance should prefer practical defaults such as `book`, `report`, thesis classes, or CJK variants only when the document profile calls for them and the local TeX installation supports them.

### Scope

May edit:

- `SKILL.md`
- `references/*.md`
- `README.md`
- `agents/openai.yaml`

Expected implementation:

- Add a book-production reference covering:
  - book profile detection
  - front matter: title page, copyright, dedication, foreword, preface, acknowledgements, abstract/summary when present, table of contents, list of figures, list of tables, notation list
  - main matter: parts, chapters, sections, theorem-like environments, formulas, figures, tables, captions, labels, cross-references, footnotes/endnotes
  - back matter: appendices, bibliography/references, glossary, index, author/date/edition notes when present
  - document IR additions for book-level structure
  - LaTeX class/package strategy for academic/technical books and theses
  - numbering strategy for chapters, equations, figures, tables, appendices, and theorem environments
  - long-document typography/readability guidance
  - book-specific refinement passes
  - book-specific quality gates
- Update routing in `SKILL.md` so Codex reads the book reference only when relevant.
- Update `pdf-analysis.md` so analysis detects book/front/main/back matter and records it.
- Update `latex-rebuild.md` so reconstruction can produce semantic book/thesis structure rather than a flat article.
- Update `latex-refinement.md` so polishing includes book-level structure, cross-reference, TOC/list/index/bibliography checks.
- Update `quality-review.md` so delivery checks include book-specific acceptance criteria.
- Update `README.md` and `agents/openai.yaml` so public-facing summaries mention book/thesis production support without overstating automation.

### Out Of Scope

Do not:

- Add a `scripts/` directory or bundled checker scripts.
- Add local OCR, cloud OCR, or external conversion dependencies.
- Change the skill into a standalone converter CLI.
- Sync changes to `~/.codex/skills/pdf-to-latex` or any installed skill directory.
- Attempt to convert an actual PDF as part of this goal.
- Make pixel-perfect book layout replication the default.
- Remove existing math-polish, goal-mode, or semantic reconstruction behavior.
- Overwrite unrelated user changes.

### Verification

Run and report:

1. Inspect changed files with `git diff`.
2. Validate the skill folder using the skill-creator validator if available, for example:

   ```bash
   /home/czc/.codex/skills/.system/skill-creator/scripts/quick_validate.py /home/czc/projects/working/pdf-to-latex
   ```

3. Run targeted text consistency checks with `rg`, including checks that:
   - `SKILL.md` routes to the new book reference.
   - `references/book-production.md` exists.
   - book guidance covers preface/front matter, table of contents, figures, formulas, tables, index/glossary, appendices, bibliography/references, and cross-references.
   - `pdf-analysis.md`, `latex-rebuild.md`, `latex-refinement.md`, and `quality-review.md` mention the book-production path.
   - `README.md` and `agents/openai.yaml` reflect the updated capability.
4. If multi-agent tools are available and appropriate, run one independent forward-test/review of the revised skill using a generic task such as:
   `Use $pdf-to-latex at /home/czc/projects/working/pdf-to-latex for an academic technical book PDF with preface, table of contents, formulas, figures, tables, appendices, bibliography, and index. Identify whether the skill tells you what to inspect, rebuild, polish, and verify.`
5. If multi-agent tools are unavailable, perform a manual equivalent review and report that substitution.
6. Confirm the final diff is limited to the intended skill files and does not introduce bundled scripts.

Completion requires validation success or a clearly documented reason a validator/reviewer could not run, plus successful manual or automated evidence that the new book workflow is discoverable from `SKILL.md` and integrated into analysis, rebuild, refinement, and quality review.

### Stop Conditions

Stop and ask before proceeding if:

- A file to be edited contains unexpected unrelated changes that make the intended edit ambiguous.
- The requested validation script is missing or fails for reasons unrelated to this change and no honest fallback is available.
- The implementation would require adding scripts, external OCR, cloud services, or system dependencies.
- Updating `agents/openai.yaml` requires metadata rules that conflict with the current skill-creator guidance.
- The new book-production guidance would make short paper conversion materially heavier by default.
- There is uncertainty about whether to overwrite or remove existing user-authored content.

## Notes

- Created for Codex Goal mode.
- Do not mark complete until the verification section passes or the user explicitly changes the completion standard.
