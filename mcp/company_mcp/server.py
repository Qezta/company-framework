"""stdio MCP server exposing read-only tools over a company spec.

Configuration (environment):
  COMPANY_SPEC        path to exports/spec.json (required)
  COMPANY_ROOT        company repository root, for policy text (optional)
  COMPANY_MODULE      company module file, e.g. qezta.nix (validate_change)
  COMPANY_POLICIES    Rego policies directory (set by the Nix wrapper)
"""

from __future__ import annotations

import os
from pathlib import Path
from typing import Any

try:  # mcp 2.x renamed FastMCP to MCPServer; same decorator and run() API.
    from mcp.server.mcpserver import MCPServer as FastMCP
except ImportError:  # mcp 1.x (e.g. nixpkgs 26.05)
    from mcp.server.fastmcp import FastMCP

from . import spec as q
from .validate import validate_change as _validate


def _env_path(name: str) -> Path | None:
    v = os.environ.get(name)
    return Path(v) if v else None


def build() -> FastMCP:
    spec_path = _env_path("COMPANY_SPEC")
    if spec_path is None or not spec_path.is_file():
        raise SystemExit("COMPANY_SPEC must point at an exports/spec.json file")
    root = _env_path("COMPANY_ROOT")
    module = _env_path("COMPANY_MODULE")
    policies = _env_path("COMPANY_POLICIES")
    mcp = FastMCP("company")

    def spec() -> dict:
        # Re-read every call so regenerated exports are picked up.
        return q.load(spec_path)

    @mcp.tool()
    def get_entity() -> dict:
        """The company's legal entity: names, jurisdiction, contacts, links, brand."""
        return q.entity(spec())

    @mcp.tool()
    def list_people(status: str | None = None) -> dict:
        """People keyed by id, optionally filtered by status
        (active, onboarding, offboarding, former)."""
        return q.people(spec(), status)

    @mcp.tool()
    def get_role(role_id: str) -> dict:
        """A role with its parent, GitHub team, responsibilities, current members and child roles."""
        return q.role(spec(), role_id)

    @mcp.tool()
    def who_owns(target: str) -> dict:
        """Who owns a system id, a repository ("Org/name"), or a path in one
        ("Org/name:path/to/file", last matching CODEOWNERS rule wins)."""
        return q.who_owns(spec(), target)

    @mcp.tool()
    def get_policy(policy_id: str) -> dict:
        """A policy's owner, review cadence, machine rules and (if available) its Markdown text."""
        return q.policy(spec(), policy_id, root)

    @mcp.tool()
    def get_process(process_id: str) -> dict:
        """A process with its trigger, inputs and steps (roles, approvers, SLAs, next steps)."""
        return q.process(spec(), process_id)

    @mcp.tool()
    def validate_change(patch: dict[str, Any]) -> dict:
        """Check a proposed change without writing anything. `patch` is shaped
        like the `company` option tree, e.g. {"people": {"ana": {...}}}. New
        entries are added; leaf values replace existing ones. Runs the full
        Nix evaluation (all assertions) and the OPA policies."""
        if module is None or policies is None:
            return {"valid": False, "evaluationError": "validate_change needs COMPANY_MODULE and COMPANY_POLICIES"}
        return _validate(patch, module, policies)

    return mcp


def main() -> None:
    build().run()


if __name__ == "__main__":
    main()
