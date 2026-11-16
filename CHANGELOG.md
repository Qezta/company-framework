# Changelog

All notable changes to this project are documented here. The format is based
on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `lib.evalCompany`, `lib.checkedFiles`, `lib.failedAssertions` and `lib.materialize`.
- Options for `company.entity`, `people`, `roles`, `domains`, `systems` and `asOf`, with cross-reference, cycle, date, email, colour and GitHub checks.
- `spec.json` exporter and its JSON Schema (`schemas/company.schema.json`).
- `flakeModules.company` with `exports`/`spec` packages, `update-exports` app and drift check.
- Fictional example company in `examples/acme`.
- Options for `policies`, `processes`, `reliability.slos`, `pricing`, `decisions`, `root`.
- Exporters: Backstage catalog, SCIM 2.0, CODEOWNERS, OPA data + Rego policies, Serverless Workflow 1.0.3, Mermaid, OpenSLO v1, AGENTS.md, llms.txt, pricing.json; disabled Pirol stub.
- `company-exports-valid` check validating every export against its standard.
- Generated `docs/options.md`, `docs/standards.md`, `nix flake init` template.
