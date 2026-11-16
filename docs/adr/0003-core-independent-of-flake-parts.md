______________________________________________________________________

## status: accepted date: 2026-11-16

# Core independent of flake-parts

## Context and Problem Statement

The framework should be usable from flake-parts flakes, plain flakes, NixOS configurations and non-flake Nix. Which parts may depend on what?

## Considered Options

- Core in `lib/` + `modules/` depending only on nixpkgs `lib`; flake-parts module as a thin wrapper
- Everything implemented as a flake-parts module

## Decision Outcome

Chosen option: "Core depends only on nixpkgs `lib`". `lib.evalCompany` wraps `lib.evalModules`; exporters return data, not derivations, so even `pkgs` is only needed by `lib.materialize`. `flakeModules.company` adds packages, the `update-exports` app and the drift check on top.

### Consequences

- Good, because the core works anywhere `lib` is available and is cheap to unit-test.
- Good, because the framework dogfoods its own flake module on `examples/acme`.
- Bad, because there are two entry points to document.
