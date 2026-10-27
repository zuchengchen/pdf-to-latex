#!/usr/bin/env bash
set -euo pipefail

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
merge="$script_dir/merge_shards.py"
report="$script_dir/report_worker_usage.py"
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/pdf-to-latex-worker-usage.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM
export PYTHONDONTWRITEBYTECODE=1

fail() {
  printf 'Worker usage test failed: %s\n' "$*" >&2
  exit 1
}

project="$tmp_dir/project"
mkdir -p "$project/work/shards/batch-v2"
python3 - "$project" <<'PY'
import json
import pathlib
import sys

project = pathlib.Path(sys.argv[1])
detail = project / "work/shards/batch-v2/details.json"
detail.write_text(json.dumps({"pages": [1, 2]}) + "\n", encoding="utf-8")
manifest = {
    "schema_version": 1,
    "source": {
        "path": "/tmp/source.pdf",
        "sha256": "a" * 64,
        "size_bytes": 123,
        "page_count": 8,
    },
    "project": {"target_directory": str(project)},
    "context": {"style_profile_sha256": "b" * 64, "document_ir_sha256": "c" * 64},
    "batches": [],
}
(project / "batch-manifest.json").write_text(
    json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
)
shard = {
    "schema_version": 2,
    "kind": "page-ir-shard",
    "batch_id": "batch-v2",
    "source": {
        "path": "/tmp/source.pdf",
        "sha256": "a" * 64,
        "size_bytes": 123,
        "page_count": 8,
    },
    "owned_pages": [1, 2],
    "context_pages": [3],
    "style_profile_sha256": "b" * 64,
    "document_ir_sha256": "c" * 64,
    "pages": [
        {
            "page": 1,
            "route": "digital-text",
            "status": "rebuilt",
            "block_count": 3,
            "object_count": 0,
            "continuity_count": 1,
            "uncertainty_count": 0,
        },
        {
            "page": 2,
            "route": "math-heavy",
            "status": "rebuilt",
            "block_count": 5,
            "object_count": 1,
            "continuity_count": 1,
            "uncertainty_count": 1,
        },
    ],
    "artifacts": ["work/shards/batch-v2/details.json"],
    "detail_artifact": "work/shards/batch-v2/details.json",
    "worker_summary": {
        "text": "Pages 1-2 rebuilt; page 2 needs parent math continuity review.",
        "owned_page_count": 2,
        "blocked_page_count": 0,
        "uncertain_page_count": 1,
    },
    "usage": {
        "input_tokens": 1000,
        "output_tokens": 300,
        "cached_input_tokens": 200,
        "reasoning_tokens": 400,
        "duration_ms": 2500,
        "retry_count": 1,
    },
    "status": "rebuilt",
}
(project / "work/shards/batch-v2/shard.json").write_text(
    json.dumps(shard, indent=2) + "\n", encoding="utf-8"
)
PY

"$merge" "$project" "$project/work/shards/batch-v2/shard.json" >/dev/null
python3 - "$project/batch-manifest.json" <<'PY'
import json
import pathlib
import sys

record = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))["batches"][0]
assert record["shard_schema_version"] == 2
assert record["summary"]["block_count"] == 8
assert record["summary"]["uncertain_page_count"] == 1
assert record["summary"]["review_required"] is True
assert record["usage"]["cached_input_tokens"] == 200
assert record["detail_artifact"] == "work/shards/batch-v2/details.json"
PY

report_json=$("$report" "$project" --format json)
python3 - "$report_json" <<'PY'
import json
import sys

report = json.loads(sys.argv[1])
assert report["input_tokens"] == 1000
assert report["cached_input_tokens"] == 200
assert report["uncached_input_tokens"] == 800
assert report["output_tokens"] == 300
assert report["retry_count"] == 1
assert report["usage_coverage"] == 1.0
assert report["cache_hit_ratio"] == 0.2
PY

python3 - "$script_dir" "$project" "$tmp_dir" <<'PY'
import json
import pathlib
import shutil
import subprocess
import sys

scripts, original, root = map(pathlib.Path, sys.argv[1:])
sys.path.insert(0, str(scripts))
from merge_shards import MergeError, merge
from report_worker_usage import UsageReportError, aggregate

valid = [
    None,
    {},
    {"cached_input_tokens": 23},
    {"input_tokens": 100},
    {"input_tokens": 0, "cached_input_tokens": 0},
    {"duration_ms": 0},
]
invalid = [
    [], "not an object", {"input_tokens": True}, {"input_tokens": -1},
    {"input_tokens": 1.5}, {"input_tokens": 1, "cached_input_tokens": 2},
    {"unknown_tokens": 1},
]
for number, usage in enumerate(valid + invalid):
    project = root / f"usage-case-{number}"
    shutil.copytree(original, project)
    ledger = project / "batch-manifest.json"
    manifest = json.loads(ledger.read_text(encoding="utf-8"))
    manifest["batches"] = []
    ledger.write_text(json.dumps(manifest), encoding="utf-8")
    before = ledger.read_bytes()
    shard_path = project / "work/shards/batch-v2/shard.json"
    shard = json.loads(shard_path.read_text(encoding="utf-8"))
    shard["usage"] = usage
    shard_path.write_text(json.dumps(shard), encoding="utf-8")
    if number >= len(valid):
        try:
            merge(str(project), [str(shard_path)])
        except MergeError:
            pass
        else:
            raise AssertionError(f"Merge accepted invalid usage: {usage}")
        try:
            aggregate({"batches": [{"owned_pages": [1], "usage": usage}]})
        except UsageReportError:
            pass
        else:
            raise AssertionError(f"Report accepted invalid usage: {usage}")
        assert ledger.read_bytes() == before
        continue
    assert merge(str(project), [str(shard_path)]) == (1, 0)
    result = subprocess.run(
        [sys.executable, str(scripts / "report_worker_usage.py"), str(project), "--format", "json"],
        capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, result.stderr
    report = json.loads(result.stdout)
    known = usage or {}
    assert report["input_tokens"] == known.get("input_tokens")
    assert report["cached_input_tokens"] == known.get("cached_input_tokens")
    assert report["usage_coverage"] == float(bool(known))
    for field, coverage in report["usage_field_coverage"].items():
        assert coverage == float(field in known), (field, report)
    complete = "input_tokens" in known and "cached_input_tokens" in known
    assert (report["uncached_input_tokens"] is not None) == complete
    assert (report["cache_hit_ratio"] is not None) == complete
    result = subprocess.run(
        [sys.executable, str(scripts / "report_worker_usage.py"), str(project)],
        capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, result.stderr
    if not complete:
        assert "Cache hit ratio: unknown" in result.stdout

mixed = aggregate({"batches": [
    {"owned_pages": [1], "usage": {"input_tokens": 1000, "cached_input_tokens": 200}},
    {"owned_pages": [2], "usage": {"cached_input_tokens": 23}},
]})
assert mixed["input_tokens"] == 1000 and mixed["cached_input_tokens"] == 223
assert mixed["usage_field_coverage"]["input_tokens"] == 0.5
assert mixed["cache_hit_ratio"] is None and mixed["uncached_input_tokens"] is None
empty = aggregate({"batches": []})
assert empty["input_tokens"] is None and empty["usage_coverage"] == 0.0
try:
    aggregate({"batches": [{"owned_pages": [[]], "history": [{"owned_pages": [1]}]}]})
except UsageReportError as exc:
    assert "invalid owned_pages" in str(exc)
else:
    raise AssertionError("Expected malformed attempt coverage to be rejected")
PY

printf 'Worker usage tests passed.\n'
