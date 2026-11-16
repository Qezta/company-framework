# Concepts

## Three layers

1. **Source**: Nix modules for structured facts, Markdown for prose. Only the source is edited by hand.
1. **Interchange**: files in standard formats generated from the source (`spec.json` today; Backstage, SCIM, CODEOWNERS, OPA, Serverless Workflow, OpenSLO and AGENTS.md next).
1. **Execution**: whatever tools read those files. They never read Nix.

## Evaluation

`lib.evalCompany` runs `lib.evalModules` over the framework's modules plus
yours. Exporters do not write files: each adds `{ format; value; }` entries
to `output.files`, keyed by relative path. `lib.materialize` serializes that
map into a directory. Keeping exporters pure data means they can be tested
without building anything and the core never needs `pkgs`.

## Assertions and warnings

Assertions are collected, not thrown one at a time. `checkedFiles` throws
once with every failure listed; `failedAssertions` returns them as data,
which is how negative tests match messages.

## Dates

Evaluation is pure and cannot read the clock. Dates are validated as real
calendar dates, and anything relative to "today" uses `company.asOf`.

## Committed exports

Exports are committed next to the source and a check fails when they drift,
so consumers can read them straight from the repository. Because flakes only
see tracked files, run `git add` on the exports directory after regenerating.
