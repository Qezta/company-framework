______________________________________________________________________

## status: accepted date: 2026-11-16

# Record architecture decisions

## Context and Problem Statement

The framework will make many structural choices (data model, formats, tooling) that future contributors and agents need to understand and revisit.

## Considered Options

- Architecture Decision Records in MADR 4.0 format
- Free-form notes in the README
- No written record

## Decision Outcome

Chosen option: "MADR 4.0 records in `docs/adr/`", because the format is widely used, lightweight, and keeps context, options and consequences together. Smaller choices go in `docs/DECISIONS-LOG.md`.

### Consequences

- Good, because decisions stay discoverable and reviewable in pull requests.
- Bad, because records must be written and superseded deliberately rather than edited away.
