#!/usr/bin/env bash
set -euo pipefail

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
merge="$script_dir/merge_shards.py"
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/pdf-to-latex-shards.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM
export PYTHONDONTWRITEBYTECODE=1

fail() {
  printf 'Shard merge test failed: %s\n' "$*" >&2
  exit 1
}

expect_failure() {
  if "$@" >"$tmp_dir/last.stdout" 2>"$tmp_dir/last.stderr"; then
    fail "expected command to fail: $*"
  fi
}

assert_hash() {
  expected=$1
  path=$2
  actual=$(python3 - "$path" <<'PY'
import hashlib
import pathlib
import sys

print(hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).hexdigest())
PY
)
  [[ "$actual" == "$expected" ]] || fail "manifest changed unexpectedly: $path"
}

hash_file() {
  python3 - "$1" <<'PY'
import hashlib
import pathlib
import sys

print(hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).hexdigest())
PY
}

make_project() {
  project=$1
  mkdir -p "$project/work/shards"
  python3 - "$project" <<'PY'
import json
import pathlib
import sys

project = pathlib.Path(sys.argv[1])
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
PY
}

write_shard() {
  project=$1
  relative=$2
  batch_id=$3
  owned_pages=$4
  source_sha=${5:-$(printf '%064d' 0)}
  artifact_relative=${6:-"$relative.artifact"}
  status=${7:-rebuilt}
  python3 - "$project" "$relative" "$batch_id" "$owned_pages" "$source_sha" "$artifact_relative" "$status" <<'PY'
import json
import pathlib
import sys

project = pathlib.Path(sys.argv[1])
relative = pathlib.Path(sys.argv[2])
batch_id = sys.argv[3]
pages = [int(item) for item in sys.argv[4].split(",") if item]
source_sha = sys.argv[5]
artifact = pathlib.Path(sys.argv[6])
status = sys.argv[7]
shard_path = project / relative
artifact_path = project / artifact
shard_path.parent.mkdir(parents=True, exist_ok=True)
artifact_path.parent.mkdir(parents=True, exist_ok=True)
artifact_path.write_text("artifact for " + batch_id, encoding="utf-8")
records = [
    {
        "page": page,
        "route": "digital-text",
        "status": status,
        "blocks": [],
        "objects": [],
        "continuity": [],
        "uncertainties": [],
    }
    for page in pages
]
shard = {
    "schema_version": 1,
    "kind": "page-ir-shard",
    "batch_id": batch_id,
    "source": {
        "path": "/tmp/source.pdf",
        "sha256": source_sha,
        "size_bytes": 123,
        "page_count": 8,
    },
    "owned_pages": pages,
    "context_pages": [],
    "style_profile_sha256": "b" * 64,
    "document_ir_sha256": "c" * 64,
    "pages": records,
    "artifacts": [artifact.as_posix()],
    "status": status,
}
shard_path.write_text(json.dumps(shard, indent=2) + "\n", encoding="utf-8")
PY
}

[[ -x "$merge" ]] || fail 'merge_shards.py must be executable'

project="$tmp_dir/project"
make_project "$project"
source_sha=$(printf 'a%.0s' {1..64})
other_sha=$(printf 'b%.0s' {1..64})
write_shard "$project" work/shards/batch-a/shard.json batch-a 1,2 "$source_sha" \
  work/shards/batch-a/page-001.json
write_shard "$project" work/shards/batch-b/shard.json batch-b 3 "$source_sha" \
  work/shards/batch-b/page-003.json
"$merge" "$project" \
  "$project/work/shards/batch-a/shard.json" \
  "$project/work/shards/batch-b/shard.json" >/dev/null
python3 - "$project/batch-manifest.json" <<'PY'
import json
import pathlib
import sys

manifest = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
assert [record["batch_id"] for record in manifest["batches"]] == ["batch-a", "batch-b"]
assert manifest["batches"][0]["owned_pages"] == [1, 2]
assert manifest["batches"][1]["owned_pages"] == [3]
assert manifest["batches"][0]["shard"] == "work/shards/batch-a/shard.json"
assert len(manifest["batches"][0]["artifacts"][0]["sha256"]) == 64
PY

before=$(python3 - "$project/batch-manifest.json" <<'PY'
import hashlib
import pathlib
import sys

print(hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).hexdigest())
PY
)
"$merge" "$project" "$project/work/shards/batch-a/shard.json" >/dev/null
assert_hash "$before" "$project/batch-manifest.json"

write_shard "$project" work/shards/batch-c/shard.json batch-c 2 "$source_sha" \
  work/shards/batch-c/page-002.json
before=$(hash_file "$project/batch-manifest.json")
expect_failure "$merge" "$project" "$project/work/shards/batch-c/shard.json"
assert_hash "$before" "$project/batch-manifest.json"

write_shard "$project" work/shards/batch-bad-source/shard.json batch-bad-source 4 "$other_sha" \
  work/shards/batch-bad-source/page-004.json
before=$(hash_file "$project/batch-manifest.json")
expect_failure "$merge" "$project" "$project/work/shards/batch-bad-source/shard.json"
assert_hash "$before" "$project/batch-manifest.json"

write_shard "$project" work/shards/batch-missing/shard.json batch-missing 5,6 "$source_sha" \
  work/shards/batch-missing/page-005.json
python3 - "$project/work/shards/batch-missing/shard.json" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
shard = json.loads(path.read_text(encoding="utf-8"))
shard["pages"] = shard["pages"][:1]
path.write_text(json.dumps(shard, indent=2) + "\n", encoding="utf-8")
PY
before=$(hash_file "$project/batch-manifest.json")
expect_failure "$merge" "$project" "$project/work/shards/batch-missing/shard.json"
assert_hash "$before" "$project/batch-manifest.json"

outside="$tmp_dir/outside-artifact.txt"
printf 'outside\n' >"$outside"
symlink_shard="$project/work/shards/batch-symlink/shard.json"
write_shard "$project" work/shards/batch-symlink/shard.json batch-symlink 7 "$source_sha" \
  work/shards/batch-symlink/link.txt
rm "$project/work/shards/batch-symlink/link.txt"
ln -s "$outside" "$project/work/shards/batch-symlink/link.txt"
before=$(hash_file "$project/batch-manifest.json")
expect_failure "$merge" "$project" "$symlink_shard"
assert_hash "$before" "$project/batch-manifest.json"

python3 - "$script_dir" "$tmp_dir" "$project/batch-manifest.json" <<'PY'
import copy
import json
import pathlib
import subprocess
import sys

scripts, root, template_path = map(pathlib.Path, sys.argv[1:])
sys.path.insert(0, str(scripts))
from merge_shards import MergeError, merge
from report_worker_usage import aggregate

template = json.loads(template_path.read_text(encoding="utf-8"))
template["batches"] = []


def project_at(name):
    project = root / name
    project.mkdir()
    (project / "batch-manifest.json").write_text(json.dumps(template), encoding="utf-8")
    return project


def write_attempt(project, name, *, batch_id="retry", page=1, status="rebuilt", version=1):
    folder = project / "work/shards" / name
    folder.mkdir(parents=True)
    detail = folder / "details.json"
    detail.write_text(json.dumps({"page": page, "text": name}), encoding="utf-8")
    record = {
        "page": page, "route": "digital-text", "status": status,
        "blocks": [], "objects": [], "continuity": [], "uncertainties": [],
    }
    shard = {
        "schema_version": version, "kind": "page-ir-shard", "batch_id": batch_id,
        "source": template["source"], "owned_pages": [page], "context_pages": [],
        **template["context"], "status": status, "pages": [record],
        "artifacts": [detail.relative_to(project).as_posix()],
        "usage": {"input_tokens": 100, "cached_input_tokens": 20},
    }
    if status == "blocked":
        for item in (shard, record):
            item.update(reason="Formula unreadable", next_action="Inspect a larger crop")
    if version == 2:
        for field in ("blocks", "objects", "continuity", "uncertainties"):
            record.pop(field)
        record.update(block_count=1, object_count=0, continuity_count=0, uncertainty_count=0)
        shard["detail_artifact"] = shard["artifacts"][0]
        shard["worker_summary"] = {
            "text": "One page reconstructed", "owned_page_count": 1,
            "blocked_page_count": int(status == "blocked"), "uncertain_page_count": 0,
        }
    path = folder / "shard.json"
    path.write_text(json.dumps(shard), encoding="utf-8")
    return path


def reject(project, paths, message, replacements=None):
    ledger = project / "batch-manifest.json"
    before = ledger.read_bytes()
    try:
        merge(str(project), [str(path) for path in paths], replace_batches=replacements)
    except MergeError as exc:
        assert message in str(exc), str(exc)
    else:
        raise AssertionError("Expected merge rejection")
    assert ledger.read_bytes() == before, "Rejected merge modified the ledger"


project = project_at("retry-project")
ledger = project / "batch-manifest.json"
first = write_attempt(project, "attempt-1", status="blocked")
assert merge(str(project), [str(first)]) == (1, 0)
original = json.loads(ledger.read_text(encoding="utf-8"))["batches"][0]
first_bytes = first.read_bytes()
retry = write_attempt(project, "attempt-2", version=2)
reject(project, [retry], "different shard hash")
other_id = write_attempt(project, "other-id", batch_id="other")
reject(project, [other_id], "already owned")
reject(project, [retry], "unknown batch", ["missing"])
reject(project, [other_id], "no supplied shard", ["retry"])
reject(project, [retry], "distinct batch", ["retry", "retry"])
reject(project, [first, retry], "appears more than once", ["retry"])
other_page = write_attempt(project, "other-page", page=2)
reject(project, [other_page], "preserve owned_pages", ["retry"])
wrong_source = write_attempt(project, "wrong-source")
shard = json.loads(wrong_source.read_text(encoding="utf-8"))
shard["source"]["sha256"] = "d" * 64
wrong_source.write_text(json.dumps(shard), encoding="utf-8")
reject(project, [wrong_source], "source identity", ["retry"])

old_detail = project / original["artifacts"][0]["path"]
detail_bytes = old_detail.read_bytes()
old_detail.write_text("overwritten", encoding="utf-8")
reject(project, [retry], "previous attempt file changed", ["retry"])
old_detail.write_bytes(detail_bytes)

# A late collision must roll back the entire replacement request.
reject(project, [retry, other_id], "already owned", ["retry"])
result = subprocess.run(
    [sys.executable, str(scripts / "merge_shards.py"), str(project), str(retry),
     "--replace-batch", "retry"], capture_output=True, text=True, check=False,
)
assert result.returncode == 0, result.stderr
manifest = json.loads(ledger.read_text(encoding="utf-8"))
active = manifest["batches"][0]
assert len(manifest["batches"]) == 1
assert active["attempt"] == 2 and active["status"] == "rebuilt"
assert active["owned_pages"] == [1]
assert active["history"] == [original]
assert first.read_bytes() == first_bytes and old_detail.read_bytes() == detail_bytes
assert "reason" not in active and "next_action" not in active
before = ledger.read_bytes()
assert merge(str(project), [str(retry)], replace_batches=["retry"]) == (0, 1)
assert ledger.read_bytes() == before

# Retry a now-stale rebuilt result without nesting or losing attempt history.
third = write_attempt(project, "attempt-3", version=2)
assert merge(str(project), [str(third)], replace_batches=["retry"]) == (1, 0)
manifest = json.loads(ledger.read_text(encoding="utf-8"))
active = manifest["batches"][0]
assert active["attempt"] == 3 and len(active["history"]) == 2
assert all("history" not in item for item in active["history"])
assert [item["status"] for item in active["history"]] == ["blocked", "rebuilt"]
report = aggregate(manifest)
assert report["page_count"] == 1 and report["batch_count"] == 1
assert report["attempt_count"] == 3
assert report["input_tokens"] == 300 and report["cached_input_tokens"] == 60
assert report["uncached_input_tokens"] == 240 and report["cache_hit_ratio"] == 0.2

valid_bytes = ledger.read_bytes()
for field, value, message in (
    ("attempt", 5, "consecutive"),
    ("batch_id", "another-batch", "preserve batch_id"),
    ("owned_pages", [2], "preserve owned_pages"),
    ("history", [], "must not be nested"),
    ("usage", {"input_tokens": -1}, "non-negative"),
):
    invalid = copy.deepcopy(manifest)
    invalid["batches"][0]["history"][0][field] = value
    ledger.write_text(json.dumps(invalid), encoding="utf-8")
    reject(project, [third], message)
    ledger.write_bytes(valid_bytes)

# Bound context hashes are mandatory for both supported shard formats.
for version in (1, 2):
    for field in template["context"]:
        for invalid in ("missing", None, "d" * 64):
            project = project_at(f"snapshot-{version}-{field}-{invalid}")
            path = write_attempt(project, "candidate", version=version)
            shard = json.loads(path.read_text(encoding="utf-8"))
            if invalid == "missing":
                shard.pop(field)
            else:
                shard[field] = invalid
            path.write_text(json.dumps(shard), encoding="utf-8")
            reject(project, [path], field)

# Binding a previously unbound context is independent of request order.
for reverse in (False, True):
    project = project_at(f"initial-binding-{reverse}")
    ledger = project / "batch-manifest.json"
    manifest = copy.deepcopy(template)
    manifest["context"] = {}
    ledger.write_text(json.dumps(manifest), encoding="utf-8")
    legacy = write_attempt(project, "legacy", batch_id="legacy")
    shard = json.loads(legacy.read_text(encoding="utf-8"))
    for field in template["context"]:
        shard.pop(field)
    legacy.write_text(json.dumps(shard), encoding="utf-8")
    bound = write_attempt(project, "bound", batch_id="bound", page=2)
    paths = [legacy, bound]
    reject(project, paths[::-1] if reverse else paths, "must provide")
    assert merge(str(project), [str(legacy)]) == (1, 0)
PY

printf 'Shard merge tests passed.\n'
