#!/usr/bin/env bash
set -euo pipefail

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
planner="$script_dir/plan_batches.py"
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/pdf-to-latex-batch-plan.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM
export PYTHONDONTWRITEBYTECODE=1

fail() {
  printf 'Batch planning test failed: %s\n' "$*" >&2
  exit 1
}

fake_bin="$tmp_dir/fake-bin"
mkdir -p "$fake_bin"
cat >"$fake_bin/pdfinfo" <<'PY'
#!/usr/bin/env python3
import pathlib
import re
import sys

source = pathlib.Path(sys.argv[-1])
data = source.read_text(encoding="utf-8")
match = re.search(r"^PAGES=([0-9]+)$", data, re.MULTILINE)
if not data.startswith("%PDF-") or match is None:
    raise SystemExit(1)
print(f"Pages: {match.group(1)}")
PY
cat >"$fake_bin/pdftotext" <<'PY'
#!/usr/bin/env python3
import sys

pages = [
    "Ordinary digital prose with enough words to remain a low risk page.",
    "Equation x = y + z ^ 2 and another equality a = b.",
    "",
    "Column A   Column B   Column C\n1   2   3",
    "Another ordinary digital prose page.",
    "A final ordinary digital prose page.",
]
if "-f" in sys.argv:
    page = int(sys.argv[sys.argv.index("-f") + 1])
    sys.stdout.write(pages[page - 1])
else:
    sys.stdout.write("\f".join(pages) + "\f")
PY
chmod 755 "$fake_bin/pdfinfo" "$fake_bin/pdftotext"
export PATH="$fake_bin:$PATH"

source_pdf="$tmp_dir/source.pdf"
printf '%%PDF-1.7\nPAGES=6\n' >"$source_pdf"
project="$tmp_dir/project"
mkdir -p "$project/work" "$project/logs"

"$planner" "$source_pdf" "$project" \
  --source-kind digital --traits none >/dev/null

python3 - "$project/work/page-index.json" <<'PY'
import json
import pathlib
import sys

index = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
assert index["kind"] == "page-complexity-index"
assert index["source"]["page_count"] == 6
pages = {record["page"]: record for record in index["pages"]}
assert pages[1]["complexity"] == "low"
assert pages[2]["route"] == "math-heavy"
assert pages[3]["complexity"] == "critical"
assert pages[3]["route"] == "visual-transcription"
assert pages[4]["route"] == "table-heavy"
assert pages[5]["complexity"] == "low"
assert pages[6]["complexity"] == "low"
batches = index["batches"]
owned = [page for batch in batches for page in batch["owned_pages"]]
assert owned == list(range(1, 7))
assert len(owned) == len(set(owned))
low_batch = next(batch for batch in batches if batch["owned_pages"] == [5, 6])
assert low_batch["worker_mode"] == "batch"
for batch in batches:
    assert not set(batch["owned_pages"]) & set(batch["context_pages"])
PY

python3 - "$planner" "$source_pdf" "$tmp_dir" <<'PY'
import os
import pathlib
import subprocess
import sys

planner, source, root = map(pathlib.Path, sys.argv[1:])
for case in ("directory-link", "file-link", "dangling-link", "directory-at-log", "fifo-at-log", "file-at-logs"):
    project = root / case
    (project / "work").mkdir(parents=True)
    index = project / "work/page-index.json"
    index.write_text("preserve existing index\n", encoding="utf-8")
    outside = root / (case + "-outside")
    outside.mkdir()
    victim = outside / "page-triage.log"
    victim.write_text("preserve outside log\n", encoding="utf-8")
    logs = project / "logs"
    if case == "directory-link":
        logs.symlink_to(outside, target_is_directory=True)
    elif case == "file-at-logs":
        logs.write_text("not a directory\n", encoding="utf-8")
    else:
        logs.mkdir()
        log = logs / "page-triage.log"
        if case == "file-link":
            log.symlink_to(victim)
        elif case == "dangling-link":
            log.symlink_to(outside / "must-not-be-created")
        elif case == "directory-at-log":
            log.mkdir()
        else:
            os.mkfifo(log)
    result = subprocess.run(
        [sys.executable, str(planner), str(source), str(project)],
        capture_output=True, text=True, timeout=10, check=False,
    )
    assert result.returncode == 1, (case, result.stdout, result.stderr)
    assert "Batch planning failed:" in result.stderr, result.stderr
    assert victim.read_text(encoding="utf-8") == "preserve outside log\n", case
    assert not (outside / "must-not-be-created").exists(), case
    assert index.read_text(encoding="utf-8") == "preserve existing index\n", case
PY

printf 'Batch planning tests passed.\n'
