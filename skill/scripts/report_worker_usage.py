#!/usr/bin/env python3
"""Report token, cache, retry, and latency telemetry recorded in batch-manifest.json."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any, Sequence

sys.dont_write_bytecode = True

from merge_shards import MergeError, USAGE_FIELDS, batch_attempts, validate_usage  # noqa: E402


class UsageReportError(RuntimeError):
    """A user-facing worker usage report failure."""


def read_manifest(project_dir: str) -> dict[str, Any]:
    raw_project = Path(project_dir).expanduser()
    if raw_project.is_symlink():
        raise UsageReportError(f"Project directory must not be a symbolic link: {raw_project}")
    project = raw_project.resolve(strict=True)
    if not project.is_dir():
        raise UsageReportError(f"Project directory must be a real directory: {project}")
    path = project / "batch-manifest.json"
    if path.is_symlink() or not path.is_file():
        raise UsageReportError(f"Batch manifest must be a regular file: {path}")
    try:
        manifest = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise UsageReportError(f"Could not read batch manifest {path}: {exc}") from exc
    if not isinstance(manifest, dict) or not isinstance(manifest.get("batches"), list):
        raise UsageReportError(f"Batch manifest has no valid batches array: {path}")
    return manifest


def aggregate(manifest: dict[str, Any]) -> dict[str, Any]:
    totals = {field: 0 for field in USAGE_FIELDS}
    field_counts = {field: 0 for field in USAGE_FIELDS}
    batches = manifest["batches"]
    page_count = 0
    batches_with_usage = 0
    attempt_count = 0
    attempts_with_usage = 0
    missing_usage_batches: list[str] = []
    missing_usage_attempts: list[str] = []
    for index, record in enumerate(batches):
        if not isinstance(record, dict):
            raise UsageReportError(f"Manifest batch {index} is not an object.")
        batch_id = record.get("batch_id", f"batch-{index + 1}")
        pages = record.get("owned_pages", [])
        if not isinstance(pages, list):
            raise UsageReportError(f"Manifest batch {batch_id}.owned_pages is not an array.")
        page_count += len(pages)
        if record.get("usage"):
            batches_with_usage += 1
        else:
            missing_usage_batches.append(str(batch_id))
        try:
            attempts = batch_attempts(record, f"Manifest batch {batch_id}")
            for number, attempt in enumerate(attempts, start=1):
                attempt_count += 1
                values = validate_usage(
                    attempt.get("usage"), f"Manifest batch {batch_id} attempt {number}.usage"
                )
                if not values:
                    missing_usage_attempts.append(f"{batch_id}#{number}")
                    continue
                attempts_with_usage += 1
                for field, value in values.items():
                    totals[field] += value
                    field_counts[field] += 1
        except MergeError as exc:
            raise UsageReportError(str(exc)) from exc

    input_tokens = totals["input_tokens"]
    cached_tokens = totals["cached_input_tokens"]
    complete_cache_data = (
        attempt_count > 0
        and field_counts["input_tokens"] == attempt_count
        and field_counts["cached_input_tokens"] == attempt_count
    )
    return {
        "batch_count": len(batches),
        "batches_with_usage": batches_with_usage,
        "missing_usage_batches": missing_usage_batches,
        "attempt_count": attempt_count,
        "attempts_with_usage": attempts_with_usage,
        "missing_usage_attempts": missing_usage_attempts,
        "page_count": page_count,
        **{field: totals[field] if field_counts[field] else None for field in USAGE_FIELDS},
        "uncached_input_tokens": input_tokens - cached_tokens if complete_cache_data else None,
        "usage_coverage": round(attempts_with_usage / attempt_count, 4) if attempt_count else 0.0,
        "usage_field_coverage": {
            field: round(count / attempt_count, 4) if attempt_count else 0.0
            for field, count in field_counts.items()
        },
        "cache_hit_ratio": (
            (round(cached_tokens / input_tokens, 4) if input_tokens else 0.0)
            if complete_cache_data else None
        ),
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("project_dir")
    parser.add_argument("--format", choices=("text", "json"), default="text")
    return parser


def print_text(report: dict[str, Any]) -> None:
    def measured(field: str) -> str:
        return "unknown" if report[field] is None else str(report[field])

    print("Worker usage report")
    print(f"Batches: {report['batch_count']} ({report['batches_with_usage']} with usage)")
    print(f"Attempts: {report['attempt_count']} ({report['attempts_with_usage']} with usage)")
    print(f"Pages: {report['page_count']}")
    print(f"Input tokens: {measured('input_tokens')}")
    print(f"Cached input tokens: {measured('cached_input_tokens')}")
    print(f"Uncached input tokens: {measured('uncached_input_tokens')}")
    print(f"Output tokens: {measured('output_tokens')}")
    print(f"Reasoning tokens: {measured('reasoning_tokens')}")
    print(f"Retries: {measured('retry_count')}")
    print(f"Duration ms: {measured('duration_ms')}")
    print(f"Usage coverage: {report['usage_coverage']:.1%}")
    ratio = report["cache_hit_ratio"]
    print("Cache hit ratio: " + ("unknown" if ratio is None else f"{ratio:.1%}"))
    print("Totals include only reported values; per-field attempt coverage:")
    for field, coverage in report["usage_field_coverage"].items():
        print(f"  {field}: {coverage:.1%}")
    if report["missing_usage_attempts"]:
        print("Missing usage: " + ", ".join(report["missing_usage_attempts"]))


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        report = aggregate(read_manifest(args.project_dir))
    except (OSError, UsageReportError, ValueError) as exc:
        print(f"Worker usage report failed: {exc}", file=sys.stderr)
        return 1
    if args.format == "json":
        print(json.dumps(report, ensure_ascii=True, indent=2, sort_keys=True))
    else:
        print_text(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
