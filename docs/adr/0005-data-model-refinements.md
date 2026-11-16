______________________________________________________________________

## status: accepted date: 2026-11-16

# Refinements to the draft data model

## Context and Problem Statement

The project brief sketched a `company.*` option tree. Implementing every exporter showed where it was missing information a standard requires, or held fields nothing used.

## Decision Outcome

Changes from the draft, each driven by an exporter or check:

- **Added `company.root`** (path) and kept every Markdown reference a string relative to it. Paths never leak into exports as `/nix/store/...`, and doc existence is checked purely.
- **Added `company.asOf`**: evaluation cannot read the clock; "overdue" checks need a reference date. OPA falls back to the real clock when it is null.
- **Added `systems.<id>.description`**: Backstage and AGENTS.md need it.
- **Made `systems.<id>.domain` optional**, and mapped each domain to a Backstage `Domain` plus a `System` of the same name that groups the domain's components.
- **Mapped `type = "infrastructure"` to a Backstage `Resource`**, everything else to a `Component`.
- **Added `reliability.slos.<id>.metricSource`** (`type`, `spec.good`, `spec.total`): OpenSLO cannot express an indicator without a metric source.
- **Constrained process graphs**: only `decision` steps may branch; decisions need at least two branches; approvals need approvers; process ids must be DNS-label style. These make the Serverless Workflow mapping unambiguous (one `then` per task, `switch` for decisions).
- **Made `decisions` read-only and discovered**: titles from the first `# ` heading, `status`/`date` from a minimal frontmatter reader. Not a YAML parser, but pure and IFD-free.
- **Kept people out of agent context files**: AGENTS.md and llms.txt get synced into possibly public repositories.

### Consequences

- Good, because every field is consumed by at least one exporter or check.
- Bad, because `metricSource` makes SLOs more verbose than the draft.
