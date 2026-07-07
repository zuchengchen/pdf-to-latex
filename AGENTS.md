# Repository Guidelines

## Project Structure & Module Organization

This repository publishes a PDF-to-LaTeX Codex skill. The installable skill lives in `skill/`; do not treat the repository root as the skill root. Keep human-facing docs in `README.md` and `INSTALL.md`, and keep development goal records in `dev-goals/`.

Inside `skill/`, `SKILL.md` is the trigger and workflow entry point. Detailed procedural guidance belongs in `skill/references/`. UI metadata lives in `skill/agents/openai.yaml`. Helper utilities live in `skill/scripts/`.

## Build, Test, and Development Commands

- `python /home/czc/.codex/skills/.system/skill-creator/scripts/quick_validate.py skill` validates skill metadata and required files.
- `bash -n skill/scripts/*.sh` checks helper scripts for shell syntax errors.
- `skill/scripts/test_skill.sh` runs metadata validation when available, shell syntax checks, artifact-scan smoke tests, and scaffold-generation smoke tests.
- `skill/scripts/init_latex_project.sh source.pdf latex standard` creates a resumable conversion scaffold from bundled templates.
- `skill/scripts/render_pdf_pages.sh source.pdf latex 180` renders durable page evidence for a sample PDF.
- `skill/scripts/latex_healthcheck.sh latex main.tex` compiles a generated XeLaTeX project and summarizes log findings.
- `skill/scripts/check_latex_artifacts.sh latex` scans final LaTeX source for extraction artifacts.

There is no package build step; the deliverable is `skill/`.

## Coding Style & Naming Conventions

Write Markdown instructions in clear imperative language. Keep `SKILL.md` concise and route details to one-level reference files under `skill/references/`. Use lowercase hyphenated names for skill and reference files, and snake_case for generated conversion artifacts such as `conversion-state.md` and `glyph-map.md`.

Shell scripts should use Bash with `set -euo pipefail`, quote variables, validate arguments, and avoid hidden network or OCR dependencies. Quote YAML strings in `openai.yaml`.

## Testing Guidelines

Run `quick_validate.py skill` after any change to `skill/SKILL.md`, `skill/agents/`, or the skill directory layout. Run `bash -n skill/scripts/*.sh` after script edits, or run `skill/scripts/test_skill.sh` for the combined local smoke suite. For workflow changes, test helper scripts against a small sample PDF or generated LaTeX project when practical, and record any manual verification in the PR.

## Commit & Pull Request Guidelines

Use concise imperative commit subjects, matching the existing history: `Add ...`, `Refine ...`, `Document ...`, `Restructure ...`. Keep the first line focused and under about 72 characters.

Pull requests should describe the behavioral change, list validation commands run, and call out install-path changes such as `skill/` versus repository root. Include before/after examples when changing prompts, metadata, or workflow rules.

## Agent-Specific Instructions

Do not add local OCR, cloud OCR, or a bundled converter unless the project direction changes explicitly. Keep generated PDF conversion outputs out of the repository; the repo should contain reusable skill instructions, references, metadata, and helper scripts only.

After completing repository changes, run relevant validation, stage only task-related files, and create a git commit automatically unless the user explicitly says not to. Do not push unless asked.
