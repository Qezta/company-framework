## The MCP server package and its tests (unit tests + a stdio round trip).
{
  perSystem = {
    pkgs,
    self',
    ...
  }: let
    server = pkgs.callPackage ../pkgs/company-mcp.nix {};
    python = pkgs.python3.withPackages (ps: [ps.mcp ps.pytest]);
  in {
    packages.company-mcp = server;

    checks.mcp = pkgs.runCommand "company-mcp-tests" {} ''
      export PYTHONPATH=${../mcp} HOME=$TMPDIR
      export ACME_EXPORTS=${self'.packages.exports} ACME_ROOT=${../examples/acme}
      ## Run from a local copy: pytest otherwise walks /nix/store for a rootdir.
      cp -r ${../tests/mcp} tests && chmod -R u+w tests
      ${python}/bin/python -m pytest -q -p no:cacheprovider --rootdir=$PWD -c /dev/null tests/test_spec.py
      COMPANY_SPEC=$ACME_EXPORTS/spec.json COMPANY_ROOT=$ACME_ROOT \
        ${python}/bin/python ${../tests/mcp/smoke.py} ${pkgs.lib.getExe server}
      touch $out
    '';
  };
}
