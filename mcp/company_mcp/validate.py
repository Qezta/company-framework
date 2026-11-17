"""validate_change: re-run the real Nix evaluation with a patch overlaid,
then the OPA policies. Needs `nix` on PATH and the company module file."""

from __future__ import annotations

import json
import os
import subprocess
import tempfile
from pathlib import Path

# Leaves get priority 50 so a patch can replace existing values; attribute
# sets merge, so new entries (a person, a system) are simply added.
EXPR = r"""
let
  lib = import (builtins.getEnv "COMPANY_MCP_NIXPKGS_LIB");
  c = import ((builtins.getEnv "COMPANY_MCP_FRAMEWORK") + "/lib") { inherit lib; };
  patch = builtins.fromJSON (builtins.readFile (builtins.getEnv "COMPANY_MCP_PATCH"));
  toDefs = v: if builtins.isAttrs v then lib.mapAttrs (_: toDefs) v else lib.mkOverride 50 v;
  e = c.evalCompany {
    modules = [ (import (builtins.getEnv "COMPANY_MCP_MODULE")) { company = toDefs patch; } ];
  };
  failed = c.failedAssertions e.config;
in {
  inherit failed;
  warnings = e.config.warnings;
  opa = if failed == [] then e.config.output.files."opa/data.json".value or null else null;
}
"""


def validate_change(patch: dict, module: Path, policies: Path) -> dict:
    """Evaluate the company with `patch` (shaped like `company.*`) applied."""
    with tempfile.TemporaryDirectory() as tmp:
        patch_file = Path(tmp) / "patch.json"
        patch_file.write_text(json.dumps(patch))
        env = dict(os.environ, COMPANY_MCP_PATCH=str(patch_file), COMPANY_MCP_MODULE=str(module))
        r = subprocess.run(
            ["nix", "eval", "--impure", "--json", "--expr", EXPR],
            capture_output=True, text=True, env=env, timeout=300,
        )
        if r.returncode != 0:
            # Type errors and conflicting definitions surface here.
            lines = [l for l in r.stderr.splitlines() if l.strip()]
            return {"valid": False, "evaluationError": "\n".join(lines[-12:])}
        result = json.loads(r.stdout)
        deny: list[str] = []
        warn: list[str] = []
        if result["opa"] is not None:
            data_file = Path(tmp) / "data.json"
            data_file.write_text(json.dumps(result["opa"]))
            for name, out in (("deny", deny), ("warn", warn)):
                o = subprocess.run(
                    ["opa", "eval", "-f", "json", "-d", str(policies), "-d", str(data_file),
                     f"data.policies.company.{name}"],
                    capture_output=True, text=True, check=True, timeout=120,
                )
                out.extend(json.loads(o.stdout)["result"][0]["expressions"][0]["value"])
    return {
        "valid": not result["failed"] and not deny,
        "failedAssertions": result["failed"],
        "policyDenials": deny,
        "warnings": result["warnings"] + warn,
    }
