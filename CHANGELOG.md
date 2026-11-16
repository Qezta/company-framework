# Changelog

All notable changes to this project are documented here. The format is based
on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.1.0 (2026-11-16)


### Features

* **examples:** add fictional acme company with committed exports ([de1e7c9](https://github.com/Qezta/company-framework/commit/de1e7c971794dacba5eed2ced0fb472a0187afa9))
* **examples:** exercise every exporter in the acme example ([6a471c1](https://github.com/Qezta/company-framework/commit/6a471c1014c384d052def3c31c6624822d42286d))
* **exports:** add Backstage, SCIM, CODEOWNERS, OPA, Serverless Workflow, Mermaid, OpenSLO, AGENTS.md and pricing exporters ([c560f07](https://github.com/Qezta/company-framework/commit/c560f0771f88cf2bccf1c825bb4147a8381bb568))
* **exports:** add spec.json exporter and its JSON Schema ([8f321a0](https://github.com/Qezta/company-framework/commit/8f321a017403186fbf12cbe38e9aca2e4521f2c9))
* **flake:** add flake-parts module with exports, update app and drift check ([8f8688a](https://github.com/Qezta/company-framework/commit/8f8688a37716c525e593fffe4c5c91696be08360))
* framework core (phase 1) ([441802a](https://github.com/Qezta/company-framework/commit/441802a95e5b6a42636bf1fc21f1be66bc938740))
* **lib:** add derived facts, shared reference checks and date arithmetic ([b4edc69](https://github.com/Qezta/company-framework/commit/b4edc690343f054722e382d0607a05449ff83681))
* **lib:** add evalCompany core with date and graph helpers ([3f01b81](https://github.com/Qezta/company-framework/commit/3f01b81083a0ac73592c7e55e7f416196182d595))
* **modules:** add entity, people, roles, domains and systems options ([7737818](https://github.com/Qezta/company-framework/commit/77378186537bdeb8b5b21fc0af2b84b77a43d9a5))
* **modules:** add policies, processes, reliability, pricing and decisions ([00d13c8](https://github.com/Qezta/company-framework/commit/00d13c824baab3179449e83e170080aa6b96563e))
* standard exporters, validation and template (phase 2) ([ebd9112](https://github.com/Qezta/company-framework/commit/ebd91127f2b4b9f4122b3b7e92e0678abe6dc3a0))
* **template:** add a nix flake init template that passes its checks ([975ec8e](https://github.com/Qezta/company-framework/commit/975ec8e6ab9a045bd17137ff22074f36917acd1b))
* **validate:** validate every export against its standard ([8fbf283](https://github.com/Qezta/company-framework/commit/8fbf28362ec02615a2b08679772e5ea153c30171))


### Bug Fixes

* **ci:** keep Rego lint portable across Regal versions ([14ce037](https://github.com/Qezta/company-framework/commit/14ce037a76f314f0aa2785f0e2b8e2ce39d6167b))
* **exports:** serialize JSON and YAML in pure Nix for cross-platform stability ([fbab5ec](https://github.com/Qezta/company-framework/commit/fbab5ecb0fc6855caf842339027dbd8aa589f18e))
* **release:** start versioning at 0.1.0 ([4cef530](https://github.com/Qezta/company-framework/commit/4cef5304c1f6df80d87f803dee3e55a645bffccb))
* **release:** start versioning at 0.1.0 ([9c1fdd8](https://github.com/Qezta/company-framework/commit/9c1fdd83f8560d1af3f1e983b42c12da85dfc2f6))

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
