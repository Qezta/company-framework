# Agent instructions — company-framework

Purpose: typed Nix module system describing a company; compiles to community-standard formats.

## Golden rules

- Source of truth = `modules/` (types) + `examples/acme/` (fictional data). Exports are generated.
- After ANY change to modules or examples: `nix run .#update-exports`, `git add examples/acme/exports`, then `nix flake check -L`.
- Never hand-edit files under `*/exports/`.
- Every new option: description, example, used by ≥1 exporter or check, covered by acme + a negative test (`tests/negative/cases.nix`) if it adds an assertion.
- New exporter: vendored schema with `PROVENANCE.md`, schema check, `docs/standards.md` row, `company.exports.<name>.enable` toggle.
- The core (`lib/`, `modules/`) must not depend on flake-parts or `pkgs`; only `lib.materialize` and `flake-module.nix` take `pkgs`.
- No IFD, no network at eval, no real-world personal data. Conventional commits.
- Format with alejandra (`nix fmt`); write `## Section` comments that explain why, not what.

## Commands

- Dev shell: `nix develop`
- Format: `nix fmt`
- Full checks: `nix flake check -L`
- Regenerate golden exports: `nix run .#update-exports`
- Render workflows after editing `flake/actions/`: `nix run .#render-workflows`
