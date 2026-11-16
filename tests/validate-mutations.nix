## Proves each validator in lib/validate.nix rejects bad input: take a valid
## exports tree, break one file per case, and require the validator to fail.
## (A validator that silently skips looks exactly like one that passes.)
{
  pkgs,
  exports,
}: let
  validate = pkgs.lib.getExe (import ../lib/validate.nix {inherit pkgs;}).script;
  cases = {
    spec-json = ''jq '.people.asha.status = "retired"' spec.json > t && mv t spec.json'';
    pricing = ''jq '.currency = "inr"' pricing.json > t && mv t pricing.json'';
    scim = ''jq '.Resources[0].active = "yes"' scim/users.json > t && mv t scim/users.json'';
    backstage-name = ''yq -i 'select(document_index == 0).metadata.name = "Not A Valid Name!"' catalog/users.yaml'';
    ## Entity (reached only through the rewritten $refs) requires metadata.
    backstage-entity-ref = ''yq -i 'select(document_index == 0) |= del(.metadata)' catalog/groups.yaml'';
    serverless-workflow = ''yq -i 'del(.document.dsl)' workflows/onboarding.sw.yaml'';
    openslo = ''yq -i 'select(.kind == "SLO").apiVersion = "openslo/v9"' openslo/slos.yaml'';
    codeowners = ''echo "docs/" >> codeowners/acme-example/website/CODEOWNERS'';
    opa = ''jq '.company.people.ghost = {"status": "active", "roles": [], "githubUser": null}' opa/data.json > t && mv t opa/data.json'';
  };
  run = name: mutate: ''
    rm -rf work && cp -r ${exports} work && chmod -R u+w work
    (cd work && ${mutate})
    if ${validate} "$PWD/work" > log 2>&1; then
      echo "FAIL ${name}: broken export was accepted" >&2
      cat log >&2
      failed=1
    else
      echo "PASS ${name}"
    fi
  '';
in
  pkgs.runCommand "validate-mutations" {nativeBuildInputs = [pkgs.jq pkgs.yq-go];} ''
    failed=0
    ${pkgs.lib.concatStrings (pkgs.lib.mapAttrsToList run cases)}
    [ "$failed" = 0 ] && touch $out
  ''
