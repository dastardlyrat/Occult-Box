#!/usr/bin/env python3
"""Validate the Occult Box API documentation baseline without compiling shaders."""

from __future__ import annotations

import hashlib
import json
import subprocess
import sys
from pathlib import Path

from build_api_docs import API_ROOT, ROOT, build_index


passes = 0
failures = 0


def report(ok: bool, key: str, detail: str) -> None:
    global passes, failures
    print(f"{'PASS' if ok else 'FAIL'}|{key}|{detail}")
    if ok:
        passes += 1
    else:
        failures += 1


def main() -> int:
    required = [
        API_ROOT / "README.md",
        API_ROOT / "VERSION",
        API_ROOT / "MANIFEST.json",
        API_ROOT / "SYMBOLS.json",
        API_ROOT / "EFFECTS.md",
        API_ROOT / "INCLUDES.md",
    ]
    report(all(path.is_file() for path in required), "api_documents_present", str(API_ROOT))

    result = subprocess.run(
        [sys.executable, str(ROOT / "tools" / "build_api_docs.py"), "--check"],
        capture_output=True,
        text=True,
        check=False,
    )
    report(result.returncode == 0, "generated_documents_current", result.stdout.strip() or result.stderr.strip())

    index = build_index()
    summary = index["summary"]
    report(summary["effects"] == 36, "effect_count", str(summary["effects"]))
    report(summary["headers"] == 126, "header_count", str(summary["headers"]))
    report(summary["techniques"] == 36, "technique_count", str(summary["techniques"]))
    report(
        all(len(item["techniques"]) == 1 for item in index["sources"] if item["kind"] == "effect"),
        "one_technique_per_effect",
        "all effect files",
    )

    unresolved = [
        (entry["path"], include["requested"])
        for entry in index["sources"]
        for include in entry["includes"]
        if include["resolved"] is None and include["requested"] != "ReShade.fxh"
    ]
    report(not unresolved, "local_includes_resolve", json.dumps(unresolved))

    api_copies = [
        ROOT / entry["path"]
        for entry in index["sources"]
        if Path(entry["path"]).name == "MIXSR_API_LoopSafe.fxh"
    ]
    api_hashes = {hashlib.sha256(path.read_bytes()).hexdigest().upper() for path in api_copies}
    report(len(api_copies) == 3, "named_api_copy_count", str(len(api_copies)))
    report(len(api_hashes) == 1, "named_api_copies_identical", ",".join(sorted(api_hashes)))

    root_readme = (ROOT / "README.md").read_text(encoding="utf-8")
    report("API/0.1.0/README.md" in root_readme, "root_readme_links_api", "README.md")
    report(
        "live visual acceptance" in (API_ROOT / "README.md").read_text(encoding="utf-8").lower(),
        "validation_boundary_visible",
        "API/0.1.0/README.md",
    )

    manifest_data = json.loads((API_ROOT / "MANIFEST.json").read_text(encoding="utf-8"))
    hash_mismatches = [
        item["path"]
        for item in manifest_data["source_files"]
        if hashlib.sha256((ROOT / item["path"]).read_bytes()).hexdigest().upper() != item["sha256"]
    ]
    report(not hash_mismatches, "manifest_hashes_match", json.dumps(hash_mismatches))

    report(
        manifest_data["source_commit"] == index["source_commit"],
        "manifest_commit_current",
        str(index["source_commit"]),
    )
    print(f"SUMMARY|{passes}/{passes + failures} passed")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
