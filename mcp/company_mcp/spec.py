"""Queries over spec.json. Pure functions, no I/O beyond reading files."""

from __future__ import annotations

import fnmatch
import json
from pathlib import Path
from typing import Any


def load(spec_path: Path) -> dict[str, Any]:
    with spec_path.open() as f:
        return json.load(f)


def entity(spec: dict) -> dict:
    return spec["entity"]


def people(spec: dict, status: str | None = None) -> dict:
    return {
        pid: p
        for pid, p in spec["people"].items()
        if status is None or p["status"] == status
    }


def role(spec: dict, role_id: str) -> dict:
    if role_id not in spec["roles"]:
        raise KeyError(f"unknown role {role_id!r}; known: {sorted(spec['roles'])}")
    r = dict(spec["roles"][role_id])
    r["members"] = sorted(
        pid
        for pid, p in spec["people"].items()
        if role_id in p["roles"] and p["status"] != "former"
    )
    r["children"] = sorted(rid for rid, x in spec["roles"].items() if x["parent"] == role_id)
    return r


def _matches(pattern: str, path: str) -> bool:
    """CODEOWNERS-style matching (gitignore subset).

    `*` matches everything; a leading `/` anchors at the repository root; a
    trailing `/` matches everything below that directory; a pattern without
    a slash matches a file or directory name at any depth.
    """
    path = path.lstrip("/")
    if pattern == "*":
        return True
    anchored = pattern.startswith("/")
    pat = pattern.strip("/")
    is_dir = pattern.endswith("/")
    if not anchored and "/" not in pat:
        parts = path.split("/")
        return any(fnmatch.fnmatchcase(part, pat) for part in (parts if is_dir else parts))
    if is_dir:
        return path == pat or path.startswith(pat + "/") or fnmatch.fnmatchcase(path, pat + "/*")
    return fnmatch.fnmatchcase(path, pat) or path.startswith(pat + "/")


def who_owns(spec: dict, target: str) -> dict:
    """Owner of a system id, a repository (`Org/name`), or a path in one
    (`Org/name:path/to/file`). For paths, the last matching CODEOWNERS rule
    wins, as on GitHub."""
    systems = spec["systems"]
    if target in systems:
        s = systems[target]
        return {"system": target, "owner": s["owner"], "repo": s["repo"], "codeowners": s["codeowners"]}

    repo, _, path = target.partition(":")
    matching = {sid: s for sid, s in systems.items() if s["repo"] == repo}
    if not matching:
        raise KeyError(f"no system or repository {repo!r}; systems: {sorted(systems)}")
    if not path:
        return {
            "repo": repo,
            "systems": {sid: {"owner": s["owner"], "description": s["description"]} for sid, s in matching.items()},
        }
    owners: list[str] = []
    rule = None
    for s in matching.values():
        for r in s["codeowners"]:
            if _matches(r["pattern"], path):
                owners, rule = r["owners"], r["pattern"]
    return {"repo": repo, "path": path, "owners": owners, "matchedRule": rule}


def policy(spec: dict, policy_id: str, root: Path | None) -> dict:
    if policy_id not in spec["policies"]:
        raise KeyError(f"unknown policy {policy_id!r}; known: {sorted(spec['policies'])}")
    p = dict(spec["policies"][policy_id])
    if root is not None and p.get("doc"):
        doc = (root / p["doc"]).resolve()
        # Never read outside the company repository.
        if root.resolve() in doc.parents and doc.is_file():
            p["text"] = doc.read_text()
    return p


def process(spec: dict, process_id: str) -> dict:
    if process_id not in spec["processes"]:
        raise KeyError(f"unknown process {process_id!r}; known: {sorted(spec['processes'])}")
    return spec["processes"][process_id]
