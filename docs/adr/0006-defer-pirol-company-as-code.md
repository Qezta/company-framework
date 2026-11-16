______________________________________________________________________

## status: accepted date: 2026-11-16

# Defer the Pirol "Company as Code" exporter

## Context and Problem Statement

[Pirol-ai/company-as-code](https://github.com/Pirol-ai/company-as-code) proposes an open standard for a company's goals, roles, processes and policies as Markdown files in git. Should this framework export to it?

At retrieval (2026-11-16) the specification was `v0.4.0` (Apache-2.0), a prose document (`spec/spec.md`) explicitly marked as a working draft to be frozen at 1.0, with no JSON Schema to validate against and a small user base.

## Considered Options

- Implement an exporter now
- Ship a disabled stub and revisit at the spec's 1.0
- Ignore it

## Decision Outcome

Chosen option: "disabled stub, revisit at 1.0", because an exporter we cannot validate against a stable spec would rot silently, and our policy is to only emit formats we can check. `company.exports.pirol.enable` exists and defaults to false; enabling it fails evaluation with a pointer to this record.

### Consequences

- Good, because the option name is reserved and the decision is discoverable.
- Bad, because users wanting the format must wait or write their own exporter module.
