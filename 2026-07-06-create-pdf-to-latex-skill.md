# Goal: Create pdf-to-latex Skill

## Goal Mode Objective

Follow the saved goal file at `/home/czc/projects/working/pdf-to-latex/2026-07-06-create-pdf-to-latex-skill.md`; complete the task only when the verification section passes, and stop to ask if any listed stop condition occurs.

## Full Prompt

### Objective

Create an English Codex skill named `pdf-to-latex` directly in `/home/czc/projects/working/pdf-to-latex`, using the current directory itself as the skill root. The skill must guide Codex agents to semantically rebuild user-provided PDF files into editable XeLaTeX projects and compiled PDFs, without installing the skill on this machine.

### Context

The target directory is currently intended to be the skill source directory, not a parent repo. The final skill should be usable later by copying or installing it elsewhere, but this task must not modify `~/.codex/skills` or Codex configuration.

The user originally considered a heavy automatic converter, then clarified that there should be no CLI and no `scripts/`; all PDF analysis, OCR judgment, LaTeX rebuilding, compiling, and review should be performed by Codex using the skill instructions, local tools, and its own visual reasoning as appropriate.

### Brainstorming Direction

Use a heavy workflow-skill design, not a converter application. Keep `SKILL.md` concise and route detailed procedures into references. Do not create a command-line product, bundled conversion scripts, or installer. Include `agents/openai.yaml` metadata.

### Discovery Summary

The skill should trigger broadly when the user asks Codex to convert, rebuild, re-typeset, or recreate a PDF as a LaTeX project and compiled PDF. It should cover both digital/selectable-text PDFs and scanned/OCR-style PDFs.

The skill should prioritize semantic rebuilding rather than pixel-level replication. It should preserve document structure, headings, body text, formulas, tables, figures, captions, references, and readable layout. It may approximate or rewrite uncertain content when needed, but must clearly mark guesses and uncertainties.

For scanned documents, prefer Codex visual reasoning over mandatory OCR. Local OCR tools such as `tesseract` or `ocrmypdf` may be used as supplements if available, but are not hard dependencies of the skill itself. Public web lookup is allowed to supplement references, paper metadata, public versions, or source context, but sourced additions must be labeled separately from PDF-derived content.

Default LaTeX engine: XeLaTeX. Default output for a user conversion task: create `latex/` next to the source PDF, containing `main.tex`, `chapters/`, `figures/`, `tables/`, and fixed `conversion-notes.md`; small documents may simplify the structure if the reason is documented.

### Scope

Create or update these core skill files in `/home/czc/projects/working/pdf-to-latex`:

- `SKILL.md`
- `agents/openai.yaml`
- `references/pdf-analysis.md`
- `references/latex-rebuild.md`
- `references/quality-review.md`

The skill body and references should be written in English and aimed primarily at Codex agents, not human end users. It should include practical workflows for PDF inspection, rendered page review, visual/OCR reasoning, semantic LaTeX reconstruction, XeLaTeX project organization, formula/table/figure/reference handling, web supplementation, uncertainty notes, compilation, and quality review.

Use `skill-creator` guidance. It is acceptable to use the official `init_skill.py` helper to create a template, then reorganize the result so the current directory is the skill root. Keep the final contents focused; avoid unnecessary README/install/changelog clutter unless a small auxiliary file is clearly useful.

### Out Of Scope

Do not install the skill into `~/.codex/skills`.

Do not modify Codex configuration.

Do not create a CLI product.

Do not create a `scripts/` directory or bundled conversion scripts.

Do not require cloud OCR APIs.

Do not promise pixel-perfect PDF recreation.

Do not keep test fixture PDFs or generated conversion artifacts in the final skill directory after verification, unless the user explicitly changes this requirement.

Do not add special copyright/permissions rules beyond Codex's normal policy behavior.

### Verification

The task is complete only when all applicable checks pass:

1. Validate the skill structure with:

```bash
python /home/czc/.codex/skills/.system/skill-creator/scripts/quick_validate.py /home/czc/projects/working/pdf-to-latex
```

2. Verify the final skill root contains valid `SKILL.md`, `agents/openai.yaml`, and the three reference files named above.

3. Create a temporary small PDF fixture outside the final skill contents. The fixture should include at least:
   - a title,
   - a paragraph,
   - a simple table or table-like content,
   - a simple formula or formula-like expression.

4. Use the new skill instructions, as a Codex agent would, to create a temporary LaTeX output project for that fixture.

5. Compile the temporary LaTeX project with XeLaTeX or an equivalent XeLaTeX-based command. The compiled PDF must be produced successfully.

6. Extract or inspect the output PDF text and confirm it includes the fixture's title, paragraph keywords, table keywords, and formula keywords.

7. Clean up temporary fixture and conversion artifacts after verification so the final skill directory remains focused.

If user-level Python packages are needed for fixture creation or PDF text extraction, they may be installed. Do not install system packages. If a required system tool such as XeLaTeX is missing, stop and report the exact missing dependency; do not mark the goal complete.

### Stop Conditions

Stop and ask the user before proceeding if:

- Completing verification would require installing system packages.
- The current directory contains unexpected existing files that would be overwritten.
- Creating the skill directly in the current directory becomes incompatible with validation.
- The implementation would require adding a CLI, bundled scripts, or installing the skill despite the stated scope.
- The required XeLaTeX compilation verification cannot be run with available system tools.
- Any requirement in this goal conflicts with a newer user instruction.

Content-level uncertainty in sample conversion is not a stop condition by itself; continue with clearly marked approximations and document them in `conversion-notes.md`.

## Notes

- Created for Codex Goal mode.
- Do not mark complete until the verification section passes or the user explicitly changes the completion standard.
