"""Unit tests for the MCP server's spec queries, against the acme example."""

import os
from pathlib import Path

import pytest

from company_mcp import spec as q

ACME = Path(os.environ["ACME_EXPORTS"])
ROOT = Path(os.environ["ACME_ROOT"])
SPEC = q.load(ACME / "spec.json")


def test_people_filter():
    assert set(q.people(SPEC)) == {"asha", "bilal", "chen", "dana"}
    assert set(q.people(SPEC, "former")) == {"dana"}


def test_role_members_exclude_former_people():
    r = q.role(SPEC, "engineering")
    assert r["members"] == ["asha"]  # dana is former
    assert r["children"] == ["platform"]


def test_unknown_role_lists_known_ones():
    with pytest.raises(KeyError, match="known"):
        q.role(SPEC, "nope")


@pytest.mark.parametrize(
    "path, owners, rule",
    [
        ("src/index.ts", ["engineering"], "*"),
        ("content/legal/terms.md", ["founder"], "/content/legal/"),
        ("docs/content/legal/x.md", ["engineering"], "*"),  # anchored rule
    ],
)
def test_who_owns_path_last_rule_wins(path, owners, rule):
    got = q.who_owns(SPEC, f"acme-example/website:{path}")
    assert got["owners"] == owners
    assert got["matchedRule"] == rule


def test_who_owns_system_and_repo():
    assert q.who_owns(SPEC, "infra")["owner"] == "platform"
    assert set(q.who_owns(SPEC, "acme-example/ui")["systems"]) == {"ui"}


def test_policy_includes_markdown_but_never_outside_root():
    p = q.policy(SPEC, "access-control", ROOT)
    assert p["rules"]["adminAllowed"] == ["founder"]
    assert p["text"].startswith("# Access control")
    escaped = dict(SPEC, policies={"x": dict(SPEC["policies"]["access-control"], doc="../../flake.nix")})
    assert "text" not in q.policy(escaped, "x", ROOT)


def test_process_steps():
    steps = [s["id"] for s in q.process(SPEC, "onboarding")["steps"]]
    assert steps[0] == "collect-details" and steps[-1] == "welcome"
