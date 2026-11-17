## stdio MCP server over a company spec (mcp/company_mcp). Bundles OPA and
## the framework's Rego policies; validate_change also needs `nix` on PATH.
{
  callPackage,
  python3,
  writeShellApplication,
  path,
}: let
  python = python3.withPackages (ps: [ps.mcp]);
  opa = callPackage ./opa.nix {};
in
  writeShellApplication {
    name = "company-mcp";
    runtimeInputs = [opa];
    text = ''
      export PYTHONPATH=${../mcp}''${PYTHONPATH:+:$PYTHONPATH}
      export COMPANY_MCP_FRAMEWORK=${../.}
      export COMPANY_MCP_NIXPKGS_LIB=${path}/lib
      export COMPANY_POLICIES="''${COMPANY_POLICIES:-${../opa/policies}}"
      exec ${python}/bin/python -m company_mcp.server "$@"
    '';
  }
