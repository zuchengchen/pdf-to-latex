# PDF to LaTeX Skill

`pdf-to-latex` is a Codex skill for rebuilding user-provided PDFs as editable,
semantic XeLaTeX projects. It supports new conversions, resumable work, broad
refinement, localized repairs, and read-only reviews of PDF-derived projects.

The normal target is maintainable LaTeX with faithful structure, text, math,
tables, figures, citations, and book apparatus. Pixel-perfect facsimiles,
full-page screenshot wrapping, OCR services, and generic PDF editing are outside
the skill's scope.

The installable skill is [`skill/`](skill/). The repository root contains
publishing, installation, and development material and is not itself a skill.

## Stable Install

In Codex, request the tagged release and the repository's `skill/` path:

```text
安装 skill https://github.com/zuchengchen/pdf-to-latex，ref 使用 v1.0.0，path 使用 skill，名称使用 pdf-to-latex
```

Equivalent installer command:

```bash
python3 "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-installer/scripts/install-skill-from-github.py" \
  --url https://github.com/zuchengchen/pdf-to-latex \
  --ref v1.0.0 \
  --path skill \
  --name pdf-to-latex
```

Restart Codex after installation. See [INSTALL.md](INSTALL.md) for atomic manual
installation, update, verification, and uninstall procedures.

## Workflow Model

The skill records independent workflow dimensions instead of a combined task
profile:

```text
Operation:          convert | resume | refine | repair | review
Source kind:        digital | scanned | mixed | unknown
Document traits:    book, long-document, math-heavy, encoded-math, cjk, visual-complex
Delivery level:     rough-draft | clean-semantic | publication-polish
Execution mode:     one-turn | resumable | goal-backed
Verification scope: source-aware | project-only
Outcome:            in-progress | complete | blocked | downgraded
```

File layout is derived from these fields. For example, book traits add stable
front/main/back matter boundaries, while math traits add math and glyph tracking.
Read-only `review` operations compile and render only in temporary copies and do
not update the user's project.

## Safety And Quality

- Ignores project `.latexmkrc` files and disables shell escape by default.
- Requires explicit approval to enable project rc execution or shell escape.
- Compiles in a temporary staged project and rejects project symlinks, hard links,
  special files, and project-external TeX inputs during final verification.
- Forces restrictive Kpathsea input/output policy and sanitizes runtime startup
  variables before invoking the toolchain.
- Classifies missing characters, missing files, undefined references, and package
  failures as blocking findings.
- Treats ordinary font substitution and box warnings as reviewable warnings.
- Uses project-closure reports and a sanitized clean-room rebuild for publication
  polish.
- Records source PDF SHA-256 identity and refuses to reuse stale page evidence.
- Writes page renders and text-layer evidence transactionally with JSON manifests.
- Makes publication findings strict by default; diagnostic overrides cannot be
  reported as a passing final gate.

## Runtime Capabilities

| Capability | Requirement | When needed |
| --- | --- | --- |
| Contract, state, evidence | Python 3.10+ | All deterministic helpers |
| Shell entrypoints | Bash 3.2+ | Wrapper commands; macOS system Bash is supported |
| Simple compilation | XeLaTeX | Rough draft and simple clean-semantic work |
| Full compilation | `latexmk` + XeLaTeX | Publication polish and complex build chains |
| PDF metadata/pages | `pdfinfo` | Full conversion, source identity, publication checks |
| Page rendering | `pdftoppm` or `mutool` | Visual analysis and comparison |
| Digital text layer | `pdftotext` | Digital evidence and output verification |
| Single-page PDFs | `pdfseparate` | Only with explicit `--single-page-pdf` |
| Bibliography/index/glossary | biber/BibTeX, makeindex, makeglossaries as used | Project-dependent |

The skill does not use `tesseract`, `ocrmypdf`, cloud OCR APIs, or a bundled
converter. Scanned pages are visually transcribed by Codex from rendered page
evidence.

## Repository Structure

```text
pdf-to-latex/
├── .github/workflows/validate.yml
├── CHANGELOG.md
├── INSTALL.md
├── LICENSE
├── README.md
├── dev-goals/
└── skill/
    ├── SKILL.md
    ├── agents/openai.yaml
    ├── assets/templates/
    ├── references/
    │   ├── workflow-contract.json
    │   ├── security-and-build.md
    │   ├── pdf-analysis.md
    │   ├── latex-rebuild.md
    │   ├── refinement-and-review.md
    │   ├── book-production.md
    │   └── math-polish.md
    └── scripts/
```

## Development Validation

Fast portable checks:

```bash
skill/scripts/test_skill.sh --portable
```

Required local integration checks:

```bash
skill/scripts/test_skill.sh --integration --require-tools
```

Metadata validation remains available directly:

```bash
python3 "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py" skill
```

CI runs portable validation and a real XeLaTeX/Poppler integration job for every
pull request. Longer bibliography, index, glossary, CJK, book, and forward-test
corpora run on scheduled or release validation.

## Usage Examples

```text
$pdf-to-latex 把 ./paper.pdf 重建成可编辑 XeLaTeX 项目并完成语义检查
```

```text
$pdf-to-latex 继续 ./latex 中上次中断的转换
```

```text
$pdf-to-latex 只读审查 ./latex，对照 ./paper.pdf 给出问题，不要修改项目
```

```text
$pdf-to-latex 修复 ./latex 中这个局部编译问题，不要展开成完整重建
```

## Versioning

Tagged releases such as `v1.0.0` are the stable installation channel. The
`main` branch is the development channel and may contain unreleased contract or
workflow changes. Workflow contract and state schema versions are recorded
separately inside `skill/references/workflow-contract.json`. Version-tag pushes
run the extended release corpus before the corresponding GitHub Release is
published.

## License

MIT License. See [LICENSE](LICENSE).
