______________________________________________________________________

## status: accepted date: 2026-11-16

# Nix as the source, standard formats as the output

## Context and Problem Statement

Company facts (people, roles, ownership, systems) are needed by many tools: catalogs, identity providers, code review, infrastructure as code, and AI agents. Where should those facts be authored, and in what form should tools receive them?

## Considered Options

- Author in Nix modules, export to each tool's standard format
- Author directly in a standard format (e.g. Backstage YAML) and convert from it
- Author in a custom DSL

## Decision Outcome

Chosen option: "Nix modules as source, standard formats as output", because the module system gives typed options, defaults, documentation and cross-reference checks for free, and exporting to standard formats means no consumer ever depends on Nix. Prose (policies, ADRs) stays in Markdown.

### Consequences

- Good, because invalid references and malformed data fail at evaluation, before any tool sees them.
- Good, because each standard is a thin, replaceable exporter.
- Bad, because authors need basic Nix; mitigated by the template and the fictional example.
