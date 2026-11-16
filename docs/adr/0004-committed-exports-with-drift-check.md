______________________________________________________________________

## status: accepted date: 2026-11-16

# Committed exports with a drift check

## Context and Problem Statement

Generated files can either be built on demand or committed. Consumers such as GitHub (CODEOWNERS), developer portals, or people without Nix need to read them directly.

## Considered Options

- Commit exports and fail CI when they differ from a fresh build
- Build exports only in CI and publish them as artifacts
- Build on demand only

## Decision Outcome

Chosen option: "Commit exports and check for drift", because it keeps the data readable without Nix and makes every change to generated output visible in review. `nix run .#update-exports` regenerates them; `checks.company-exports-drift` compares byte-for-byte.

### Consequences

- Good, because diffs show exactly how a source change affects every consumer.
- Good, because the data is not trapped if Nix is ever dropped.
- Bad, because contributors must regenerate and `git add` exports; the check's failure message says how.
- Neutral: exporters must be deterministic, so they never embed build timestamps.
