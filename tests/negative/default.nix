## Runs every case in ./cases.nix and builds a report; the derivation fails
## if any case did not fail the way it should.
{
  pkgs,
  companyLib,
  base,
}: let
  inherit (pkgs) lib;

  run = case: let
    eval = companyLib.evalCompany {modules = [base case.module];};
    failed = builtins.tryEval (let f = companyLib.failedAssertions eval.config; in builtins.deepSeq f f);
    evalBroken = !(builtins.tryEval (builtins.deepSeq eval.config.company true)).success;
    passed =
      if case.expect == null
      then evalBroken || !failed.success || failed.value != []
      else failed.success && lib.any (lib.hasInfix case.expect) failed.value;
    got =
      if failed.success
      then builtins.toJSON failed.value
      else "<evaluation error>";
  in
    if passed
    then "PASS ${case.name}"
    else "FAIL ${case.name}: expected ${builtins.toJSON case.expect}, got ${got}";

  lines = map run (import ./cases.nix);
  failures = lib.filter (lib.hasPrefix "FAIL") lines;
in
  pkgs.runCommand "company-negative-tests" {
    report = lib.concatLines lines;
    passAsFile = ["report"];
  } ''
    cat "$reportPath"
    ${lib.optionalString (failures != []) "echo '${toString (builtins.length failures)} negative test(s) failed' >&2; exit 1"}
    cp "$reportPath" $out
  ''
