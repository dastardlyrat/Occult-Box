#!/usr/bin/env python3
"""Build the evidence-derived Occult Box API 0.1.0 documentation indexes."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
API_ROOT = ROOT / "API" / "0.1.0"
FAMILIES = (
    "black_wand",
    "book_of_death",
    "depth_oracle",
    "golden_weave",
    "legacy_lenses",
)
SOURCE_SUFFIXES = {".fx", ".fxh"}


def read_source(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def line_number(source: str, offset: int) -> int:
    return source.count("\n", 0, offset) + 1


def clean_annotation(value: str | None) -> str | None:
    if value is None:
        return None
    return " ".join(value.replace("\\0", " | ").split())


def annotation_value(block: str | None, key: str) -> str | None:
    if not block:
        return None
    match = re.search(rf"\b{re.escape(key)}\s*=\s*\"(.*?)\"\s*;", block, re.DOTALL)
    return clean_annotation(match.group(1)) if match else None


def source_paths(root: Path = ROOT) -> list[Path]:
    paths: list[Path] = []
    for family in FAMILIES:
        family_root = root / family
        paths.extend(
            path
            for path in family_root.rglob("*")
            if path.is_file() and path.suffix.lower() in SOURCE_SUFFIXES
        )
    return sorted(paths, key=lambda path: path.relative_to(root).as_posix().lower())


def extract_includes(source: str) -> list[str]:
    return re.findall(r'^\s*#include\s+["<]([^">]+)[">]', source, re.MULTILINE)


def resolve_include(source_path: Path, include: str, root: Path = ROOT) -> str | None:
    normalized = include.replace("\\", "/")
    candidates = [source_path.parent / normalized, root / normalized]
    for candidate in candidates:
        if candidate.is_file():
            return candidate.resolve().relative_to(root.resolve()).as_posix()
    return None


def extract_macros(source: str) -> list[dict[str, object]]:
    output: list[dict[str, object]] = []
    for match in re.finditer(
        r"^\s*#define\s+([A-Za-z_]\w*)(?:\s+(.*?))?\s*$", source, re.MULTILINE
    ):
        name = match.group(1)
        output.append(
            {
                "name": name,
                "value": (match.group(2) or "").strip(),
                "line": line_number(source, match.start()),
                "include_guard": name.endswith(("_FXH", "_FX")),
            }
        )
    return output


def extract_structs(source: str) -> list[dict[str, object]]:
    output: list[dict[str, object]] = []
    for match in re.finditer(r"^\s*struct\s+(\w+)\s*\{(.*?)^\s*\};", source, re.MULTILINE | re.DOTALL):
        fields = [
            {"type": field.group(1), "name": field.group(2)}
            for field in re.finditer(
                r"^\s*([A-Za-z_]\w*(?:\d(?:x\d)?)?)\s+(\w+)\s*;",
                match.group(2),
                re.MULTILINE,
            )
        ]
        output.append(
            {"name": match.group(1), "line": line_number(source, match.start()), "fields": fields}
        )
    return output


def extract_functions(source: str) -> list[dict[str, object]]:
    pattern = re.compile(
        r"^\s*(?:\[[^\]]+\]\s*)?"
        r"((?:static\s+)?(?:const\s+)?[A-Za-z_]\w*(?:\d(?:x\d)?)?)\s+"
        r"([A-Za-z_]\w*)\s*\((.*?)\)\s*(?::\s*[A-Za-z_]\w*)?\s*\{",
        re.MULTILINE | re.DOTALL,
    )
    blocked = {"if", "for", "while", "switch", "technique", "pass"}
    output: list[dict[str, object]] = []
    for match in pattern.finditer(source):
        if match.group(2) in blocked:
            continue
        output.append(
            {
                "return_type": " ".join(match.group(1).split()),
                "name": match.group(2),
                "parameters": " ".join(match.group(3).split()),
                "line": line_number(source, match.start()),
            }
        )
    return output


def extract_resources(source: str) -> list[dict[str, object]]:
    pattern = re.compile(
        r"^\s*(texture(?:1D|2D|3D)?|storage(?:1D|2D|3D)?|sampler(?:1D|2D|3D)?|sampler)\s+"
        r"([A-Za-z_]\w*)\b",
        re.MULTILINE,
    )
    return [
        {"kind": match.group(1), "name": match.group(2), "line": line_number(source, match.start())}
        for match in pattern.finditer(source)
    ]


def extract_uniforms(source: str) -> list[dict[str, object]]:
    pattern = re.compile(
        r"^\s*uniform\s+([A-Za-z_]\w*(?:\d(?:x\d)?)?)\s+([A-Za-z_]\w*)\s*"
        r"(?:<(.*?)>)?\s*=\s*([^;]+);",
        re.MULTILINE | re.DOTALL,
    )
    output: list[dict[str, object]] = []
    for match in pattern.finditer(source):
        annotations = match.group(3)
        output.append(
            {
                "type": match.group(1),
                "name": match.group(2),
                "default": " ".join(match.group(4).split()),
                "line": line_number(source, match.start()),
                "ui_type": annotation_value(annotations, "ui_type"),
                "ui_label": annotation_value(annotations, "ui_label"),
                "ui_category": annotation_value(annotations, "ui_category"),
                "ui_tooltip": annotation_value(annotations, "ui_tooltip"),
                "ui_items": annotation_value(annotations, "ui_items"),
            }
        )
    return output


def extract_techniques(source: str) -> list[dict[str, object]]:
    pattern = re.compile(
        r"^\s*technique\s+([A-Za-z_]\w*)\s*(?:<(.*?)>)?\s*\{",
        re.MULTILINE | re.DOTALL,
    )
    output: list[dict[str, object]] = []
    for match in pattern.finditer(source):
        annotations = match.group(2)
        output.append(
            {
                "name": match.group(1),
                "line": line_number(source, match.start()),
                "ui_label": annotation_value(annotations, "ui_label"),
                "ui_tooltip": annotation_value(annotations, "ui_tooltip"),
            }
        )
    return output


def git_source_commit(root: Path = ROOT) -> str | None:
    result = subprocess.run(
        [
            "git",
            "-c",
            f"safe.directory={root.as_posix()}",
            "-C",
            str(root),
            "rev-list",
            "-1",
            "HEAD",
            "--",
            *FAMILIES,
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    return result.stdout.strip() if result.returncode == 0 else None


def build_index(root: Path = ROOT) -> dict[str, object]:
    entries: list[dict[str, object]] = []
    for path in source_paths(root):
        source = read_source(path)
        relative = path.relative_to(root).as_posix()
        includes = []
        for include in extract_includes(source):
            resolved = resolve_include(path, include, root)
            includes.append(
                {
                    "requested": include.replace("\\", "/"),
                    "resolved": resolved,
                    "external": resolved is None,
                }
            )
        entries.append(
            {
                "path": relative,
                "family": relative.split("/", 1)[0],
                "kind": "effect" if path.suffix.lower() == ".fx" else "header",
                "bytes": path.stat().st_size,
                "sha256": sha256(path),
                "includes": includes,
                "macros": extract_macros(source),
                "structs": extract_structs(source),
                "functions": extract_functions(source),
                "resources": extract_resources(source),
                "uniforms": extract_uniforms(source),
                "techniques": extract_techniques(source),
                "references_back_buffer": bool(re.search(r"ReShade::BackBuffer", source)),
                "references_depth": bool(
                    re.search(r"ReShade::DepthBuffer|ReShade::GetLinearizedDepth", source)
                ),
            }
        )

    by_path = {entry["path"]: entry for entry in entries}

    def closure(path: str) -> set[str]:
        seen: set[str] = set()
        pending = [path]
        while pending:
            current = pending.pop()
            if current in seen or current not in by_path:
                continue
            seen.add(current)
            pending.extend(
                item["resolved"]
                for item in by_path[current]["includes"]
                if item["resolved"] is not None
            )
        return seen

    for entry in entries:
        if entry["kind"] != "effect":
            continue
        dependency_paths = closure(entry["path"])
        entry["local_include_closure"] = sorted(dependency_paths - {entry["path"]})
        entry["uses_back_buffer"] = any(by_path[item]["references_back_buffer"] for item in dependency_paths)
        entry["uses_depth"] = any(by_path[item]["references_depth"] for item in dependency_paths)

    summary = {
        "source_files": len(entries),
        "effects": sum(entry["kind"] == "effect" for entry in entries),
        "headers": sum(entry["kind"] == "header" for entry in entries),
        "techniques": sum(len(entry["techniques"]) for entry in entries),
        "uniforms": sum(len(entry["uniforms"]) for entry in entries),
        "macros": sum(len(entry["macros"]) for entry in entries),
        "structs": sum(len(entry["structs"]) for entry in entries),
        "struct_fields": sum(
            len(struct["fields"]) for entry in entries for struct in entry["structs"]
        ),
        "functions": sum(len(entry["functions"]) for entry in entries),
        "resources": sum(len(entry["resources"]) for entry in entries),
        "local_include_edges": sum(
            item["resolved"] is not None for entry in entries for item in entry["includes"]
        ),
        "external_include_edges": sum(
            item["resolved"] is None for entry in entries for item in entry["includes"]
        ),
    }
    family_summary = []
    for family in FAMILIES:
        subset = [entry for entry in entries if entry["family"] == family]
        family_summary.append(
            {
                "family": family,
                "effects": sum(entry["kind"] == "effect" for entry in subset),
                "headers": sum(entry["kind"] == "header" for entry in subset),
                "techniques": sum(len(entry["techniques"]) for entry in subset),
                "uniforms": sum(len(entry["uniforms"]) for entry in subset),
            }
        )
    return {
        "schema": "occult-box-api-symbol-index-v1",
        "api_version": "0.1.0",
        "status": "documentation draft; extracted surface, not yet a compatibility guarantee",
        "source_commit": git_source_commit(root),
        "summary": summary,
        "families": family_summary,
        "sources": entries,
    }


def effect_docs(index: dict[str, object]) -> str:
    summary = index["summary"]
    lines = [
        "# Occult Box API 0.1.0 — Effect Interface Reference",
        "",
        "This generated reference records the ReShade-facing techniques and uniforms",
        "declared by the current source tree. Labels, tooltips, defaults, and source",
        "locations are transcribed from source; missing descriptions remain visibly",
        "missing rather than being inferred.",
        "",
        f"Coverage: **{summary['effects']} effect files · {summary['techniques']} techniques · "
        f"{summary['uniforms']} uniforms**.",
        "",
        "> `uses depth` and `uses back buffer` are derived from literal ReShade resource",
        "> references anywhere in the effect's resolved local include closure. They do",
        "> not prove correct target-game depth configuration or runtime behavior.",
        "",
        "## Catalog",
        "",
        "| Family | Effect source | Technique | Controls | Uses depth | Uses back buffer |",
        "|---|---|---|---:|:---:|:---:|",
    ]
    effects = [entry for entry in index["sources"] if entry["kind"] == "effect"]
    for entry in effects:
        techniques = ", ".join(f"`{item['name']}`" for item in entry["techniques"]) or "—"
        lines.append(
            f"| `{entry['family']}` | [`{Path(entry['path']).name}`](../../{entry['path']}) | "
            f"{techniques} | {len(entry['uniforms'])} | "
            f"{'yes' if entry['uses_depth'] else 'no'} | "
            f"{'yes' if entry['uses_back_buffer'] else 'no'} |"
        )

    for entry in effects:
        lines.extend(["", f"## `{entry['path']}`", ""])
        if entry["techniques"]:
            for technique in entry["techniques"]:
                label = technique["ui_label"] or "Source provides no `ui_label`."
                tooltip = technique["ui_tooltip"] or "Source provides no `ui_tooltip`."
                lines.extend(
                    [
                        f"### `{technique['name']}`",
                        "",
                        f"- Source line: `{technique['line']}`",
                        f"- UI label: {label}",
                        f"- UI tooltip: {tooltip}",
                        f"- Local include closure: `{len(entry['local_include_closure'])}` files",
                        f"- Derived resource flags: depth `{'yes' if entry['uses_depth'] else 'no'}`; "
                        f"back buffer `{'yes' if entry['uses_back_buffer'] else 'no'}`",
                        "",
                    ]
                )
        else:
            lines.extend(["**No technique declaration was extracted.**", ""])
        lines.extend(
            [
                "### Uniform controls",
                "",
                "| Symbol | Type | Default | UI label | Category | Tooltip |",
                "|---|---|---|---|---|---|",
            ]
        )
        if not entry["uniforms"]:
            lines.append("| — | — | — | — | — | No uniforms declared. |")
        for uniform in entry["uniforms"]:
            values = [
                uniform["name"],
                uniform["type"],
                uniform["default"],
                uniform["ui_label"] or "—",
                uniform["ui_category"] or "—",
                uniform["ui_tooltip"] or "—",
            ]
            escaped = [str(value).replace("|", "\\|").replace("\n", " ") for value in values]
            lines.append(
                f"| `{escaped[0]}` | `{escaped[1]}` | `{escaped[2]}` | {escaped[3]} | "
                f"{escaped[4]} | {escaped[5]} |"
            )
    lines.extend(
        [
            "",
            "## Validation boundary",
            "",
            "This reference establishes source declaration coverage and resolved local",
            "include relationships. It does not establish clean ReShade compilation,",
            "backend compatibility, performance, target-game depth correctness, preset",
            "quality, effect ordering, or live visual acceptance.",
            "",
        ]
    )
    return "\n".join(lines)


def include_class(path: str) -> str:
    name = Path(path).name
    if name == "MIXSR_API_LoopSafe.fxh":
        return "named API candidate"
    if name.lower().startswith("mixsr_shared_") or "_Adapter" in name:
        return "shared/support surface"
    return "family-internal surface"


def include_docs(index: dict[str, object]) -> str:
    headers = [entry for entry in index["sources"] if entry["kind"] == "header"]
    named_api_headers = [
        header for header in headers if Path(header["path"]).name == "MIXSR_API_LoopSafe.fxh"
    ]
    named_api_hashes = sorted({header["sha256"] for header in named_api_headers})
    named_api_hash = named_api_hashes[0] if len(named_api_hashes) == 1 else "DIVERGENT"
    includers: dict[str, list[str]] = defaultdict(list)
    for entry in index["sources"]:
        for include in entry["includes"]:
            if include["resolved"]:
                includers[include["resolved"]].append(entry["path"])
    lines = [
        "# Occult Box API 0.1.0 — Include Surface",
        "",
        "This generated inventory distinguishes the explicitly named API candidate from",
        "shared support headers and family-internal implementation headers. Visibility in",
        "source does not by itself create a stability promise.",
        "",
        "## Compatibility classes",
        "",
        "- **Named API candidate:** `MIXSR_API_LoopSafe.fxh`. Three families carry",
        "  byte-identical copies. Its declarations are documented below, but 0.1.0-draft",
        "  does not yet guarantee long-term source compatibility.",
        "- **Shared/support surface:** reusable `miXSR_shared_*` and adapter headers.",
        "  They are callable source, but their declarations may move while the draft is",
        "  being reconciled.",
        "- **Family-internal surface:** effect implementation and domain headers. Consumers",
        "  should include the family effect or documented umbrella header instead of",
        "  depending on these declarations directly.",
        "",
        "## Named API candidate",
        "",
        "All three copies currently have SHA-256",
        f"`{named_api_hash}`.",
        "",
        "| Signature | Source-supported behavior |",
        "|---|---|",
        "| `float MIXSR_FloatModNoWarn(float a, float b)` | Float modulo with an absolute denominator floor of `1e-6`. |",
        "| `float2 MIXSR_Float2ModNoWarn(float2 a, float2 b)` | Component-wise float2 modulo with denominator floors. |",
        "| `float3 MIXSR_Float3ModNoWarn(float3 a, float3 b)` | Component-wise float3 modulo with denominator floors. |",
        "| `int MIXSR_IntModNoWarn(int a, int b)` | Nonnegative integer-like modulo computed through floats; clamps `a` to nonnegative and `b` to at least one. |",
        "| `uint MIXSR_UIntModNoWarn(uint a, uint b)` | Unsigned integer-like modulo computed through floats; clamps `b` to at least one. |",
        "| `float MIXSR_SafePowNonNegative(float baseValue, float exponentValue)` | Applies `pow` after clamping the base to nonnegative. |",
        "| `float3 MIXSR_RM_LoopMissColor(float2 uv)` | Produces a fixed dark/red 24-cell grid diagnostic for loop-miss display. |",
        "",
        "### Current copies",
        "",
    ]
    for header in named_api_headers:
        lines.append(f"- [`{header['path']}`](../../{header['path']})")
    lines.extend(
        [
            "",
            "## Header inventory",
            "",
            "| Header | Class | Macros | Structs | Functions | Resources | Direct local includers | SHA-256 |",
            "|---|---|---:|---:|---:|---:|---:|---|",
        ]
    )
    for header in headers:
        lines.append(
            f"| [`{header['path']}`](../../{header['path']}) | {include_class(header['path'])} | "
            f"{len(header['macros'])} | {len(header['structs'])} | {len(header['functions'])} | "
            f"{len(header['resources'])} | {len(includers[header['path']])} | `{header['sha256']}` |"
        )
    lines.extend(
        [
            "",
            "## Declaration lookup",
            "",
            "`SYMBOLS.json` carries the complete extracted macro, struct/field, function,",
            "resource, uniform, technique, include-edge, source-line, byte-size, and SHA-256",
            "inventory. Use it for exact lookup rather than treating this classification",
            "table as a semantic specification for internal helpers.",
            "",
            "## Validation boundary",
            "",
            "Static extraction and hash equality establish only the present declaration",
            "surface. They do not establish consumer compilation, numerical equivalence on",
            "all backends, runtime safety, performance, or a future compatibility guarantee.",
            "",
        ]
    )
    return "\n".join(lines)


def manifest(index: dict[str, object]) -> dict[str, object]:
    return {
        "schema": "occult-box-api-documentation-manifest-v1",
        "api_version": "0.1.0",
        "status": "draft documentation baseline",
        "source_commit": index["source_commit"],
        "source_scope": list(FAMILIES),
        "summary": index["summary"],
        "families": index["families"],
        "documents": {
            "architecture_and_policy": "README.md",
            "effect_interfaces": "EFFECTS.md",
            "include_surface": "INCLUDES.md",
            "machine_index": "SYMBOLS.json",
        },
        "source_files": [
            {
                "path": entry["path"],
                "kind": entry["kind"],
                "bytes": entry["bytes"],
                "sha256": entry["sha256"],
            }
            for entry in index["sources"]
        ],
        "validation_boundary": (
            "Static documentation checks cover source presence, hashes, declaration extraction, "
            "local include resolution, generated-document currency, and README linkage. They do "
            "not attest ReShade compilation, backend compatibility, target-game depth behavior, "
            "performance, preset quality, or live visual acceptance."
        ),
    }


def generated_files(root: Path = ROOT) -> dict[Path, str]:
    index = build_index(root)
    return {
        API_ROOT / "SYMBOLS.json": json.dumps(index, indent=2) + "\n",
        API_ROOT / "MANIFEST.json": json.dumps(manifest(index), indent=2) + "\n",
        API_ROOT / "EFFECTS.md": effect_docs(index),
        API_ROOT / "INCLUDES.md": include_docs(index),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    failures = 0
    for path, content in generated_files().items():
        current = path.read_text(encoding="utf-8") if path.is_file() else ""
        if args.check:
            if current != content:
                print(f"FAIL|generated_current|regenerate {path}")
                failures += 1
            else:
                print(f"PASS|generated_current|{path}")
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding="utf-8", newline="\n")
            print(f"WROTE|{path}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
