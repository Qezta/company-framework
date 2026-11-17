## Validates an exports tree against every standard it targets. Used by the
## flake module, so every company gets these checks, not just the example.
## Each validator only runs when its files exist (exporters can be disabled);
## tests/validate-mutations.nix proves each one actually rejects bad input.
##
## Returns { script; check = { name, exports }: <derivation>; }.
{pkgs}: let
  oslo = pkgs.callPackage ../pkgs/oslo.nix {};
  schemas = ../schemas;
  backstage = ../vendor/schemas/backstage;
  serverlessWorkflow = ../vendor/schemas/serverless-workflow/workflow.yaml;
  policies = ../opa/policies;
  script = pkgs.writeShellApplication {
    name = "validate-exports";
    runtimeInputs = [pkgs.check-jsonschema pkgs.jq pkgs.yq-go pkgs.coreutils pkgs.gnugrep (pkgs.callPackage ../pkgs/opa.nix {}) oslo];
    text = ''
        cd "$1"
        TMPDIR="''${TMPDIR:-$(mktemp -d)}"
        ## True if the glob matches at least one file. (No compgen: the
        ## sandbox's non-interactive bash is built without it.)
        has() {
          local f
          # shellcheck disable=SC2086 # $1 is a glob and must expand
          for f in $1; do
            [ -e "$f" ] && return 0
          done
          return 1
        }

        if [ -f spec.json ]; then
          echo "spec.json: company schema"
          check-jsonschema --schemafile ${schemas}/company.schema.json spec.json
        fi
        if [ -f pricing.json ]; then
          echo "pricing.json: pricing schema"
          check-jsonschema --schemafile ${schemas}/pricing.schema.json pricing.json
        fi
        if [ -f public/projection.json ]; then
        echo "public/projection.json: projection schema (no personal fields)"
        check-jsonschema --schemafile ${schemas}/projection.schema.json public/projection.json
      fi
      if has 'scim/*.json'; then
          echo "scim: SCIM 2.0 schema"
          check-jsonschema --schemafile ${schemas}/scim.schema.json scim/*.json
        fi

        if has 'catalog/*.yaml'; then
          ## Backstage schemas reference each other by bare $id ("Entity",
          ## "common#relation"); point those at sibling files in a scratch copy.
          bs=$TMPDIR/backstage
          mkdir -p "$bs/docs"
          for f in ${backstage}/*.json; do
            jq 'walk(if type == "object" and has("$ref") then .["$ref"] |= (if startswith("#") then . else (split("#") | .[0] + ".schema.json" + (if length > 1 then "#" + .[1] else "" end)) end) else . end) | del(.["$id"])' \
              "$f" > "$bs/$(basename "$f")"
          done
          for file in catalog/*.yaml; do
            base=$(basename "$file" .yaml)
            yq -s "\"$bs/docs/$base-\" + \$index" -o json "$file" > /dev/null
          done
          count=0
          for doc in "$bs"/docs/*.json; do
            kind=$(jq -r .kind "$doc")
            check-jsonschema --base-uri "file://$bs/" --schemafile "$bs/$kind.v1alpha1.schema.json" "$doc" > /dev/null \
              || { echo "Backstage $kind entity $(jq -r .metadata.name "$doc") is invalid:" >&2; check-jsonschema --base-uri "file://$bs/" --schemafile "$bs/$kind.v1alpha1.schema.json" "$doc" >&2 || true; exit 1; }
            count=$((count + 1))
          done
          ## Backstage enforces entity naming in code, not in its JSON Schema
          ## (catalog-model KubernetesValidatorFunctions), so check it here.
          bad_names=$(jq -r '.metadata.name | select((length > 63) or (test("^[A-Za-z0-9]([-_.]?[A-Za-z0-9])*$") | not))' "$bs"/docs/*.json)
          if [ -n "$bad_names" ]; then
            echo "Backstage entity names must be at most 63 characters of [A-Za-z0-9] separated by single -, _ or .:" >&2
            echo "$bad_names" >&2
            exit 1
          fi
          echo "catalog: $count Backstage entities valid"
        fi

        if has 'workflows/*.sw.yaml'; then
          echo "workflows: Serverless Workflow DSL 1.0.3"
          check-jsonschema --schemafile ${serverlessWorkflow} workflows/*.sw.yaml
        fi

        if has 'openslo/*.yaml'; then
          echo "openslo: oslo validate"
          args=()
          for f in openslo/*.yaml; do args+=(-f "$f"); done
          oslo validate "''${args[@]}"
        fi

        if has 'codeowners/*/*/CODEOWNERS'; then
          echo "codeowners: syntax"
          for f in codeowners/*/*/CODEOWNERS; do
            if grep -vE '^(#.*)?$' "$f" | grep -vqE '^[^[:space:]]+([[:space:]]+@[A-Za-z0-9._/-]+)+$'; then
              echo "$f has a rule without valid @owners:" >&2
              grep -vE '^(#.*)?$' "$f" | grep -vE '^[^[:space:]]+([[:space:]]+@[A-Za-z0-9._/-]+)+$' >&2
              exit 1
            fi
          done
        fi

        if [ -f opa/data.json ]; then
          echo "opa: company policies"
          opa eval -f pretty -d ${policies} -d opa/data.json 'data.policies.company.warn' \
            | jq -r '.[]? | "warning: " + .' || true
          denied=$(opa eval -f json -d ${policies} -d opa/data.json 'data.policies.company.deny' | jq -r '.result[0].expressions[0].value[]')
          if [ -n "$denied" ]; then
            echo "Company policies denied:" >&2
            while IFS= read -r line; do echo "- $line" >&2; done <<< "$denied"
            exit 1
          fi
        fi

    '';
  };
in {
  inherit script;
  check = {
    name ? "company-exports-valid",
    exports,
  }:
    pkgs.runCommand name {} ''
      ${pkgs.lib.getExe script} ${exports}
      touch $out
    '';
}
