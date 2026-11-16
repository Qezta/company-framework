# Standards

Every export, the option it comes from, the standard it follows, how it is
validated, and who consumes it.

| Export | From | Standard | Validated by | Consumers |
| --- | --- | --- | --- | --- |
| `spec.json` | everything | Own format, [`schemas/company.schema.json`](../schemas/company.schema.json) (JSON Schema 2020-12) | `check-jsonschema` | Any tool; websites; scripts |
| `catalog/{users,groups}.yaml` | `people`, `roles` | [Backstage](https://backstage.io/docs/features/software-catalog/descriptor-format) `backstage.io/v1alpha1` `User`, `Group` | Vendored Backstage schemas (v1.56.5) | Backstage and compatible portals |
| `catalog/{domains,systems,components,resources}.yaml` | `domains`, `systems` | Backstage `Domain`, `System`, `Component`, `Resource` | Vendored Backstage schemas | Backstage and compatible portals |
| `scim/{users,groups}.json` | `people`, `roles` | [SCIM 2.0](https://www.rfc-editor.org/rfc/rfc7643) ListResponse | [`schemas/scim.schema.json`](../schemas/scim.schema.json), derived from RFC 7643/7644 | Identity providers |
| `codeowners/<Org>/<repo>/CODEOWNERS` | `systems.*.codeowners`, `roles.*.githubTeam` | [GitHub CODEOWNERS](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners) | Syntax check | GitHub (copied into each repo) |
| `opa/data.json` + [`opa/policies`](../opa/policies) | `people`, `roles`, `systems`, `reliability`, `policies.*.rules` | [Open Policy Agent](https://www.openpolicyagent.org/) / Rego v1 | `opa check --strict`, `opa test`, Regal; `deny` must be empty | OPA, CI gates |
| `workflows/<id>.sw.yaml` | `processes` | [CNCF Serverless Workflow](https://serverlessworkflow.io) DSL 1.0.3 | Vendored workflow schema | Workflow runtimes |
| `diagrams/<id>.mmd` | `processes` | [Mermaid](https://mermaid.js.org) flowchart | (rendered by consumers) | Docs, READMEs, GitHub |
| `openslo/{services,slos}.yaml` | `reliability.slos` | [OpenSLO](https://openslo.com) v1 | `oslo validate` (OpenSLO/oslo v0.13.0) | SLO tooling |
| `agents/AGENTS.md`, `agents/<Org>/<repo>/AGENTS.md` | everything except people | [AGENTS.md](https://agents.md) convention | (Markdown) | AI coding agents |
| `llms.txt` | entity, systems | [llms.txt](https://llmstxt.org) proposal | (Markdown) | LLM tools |
| `pricing.json` | `pricing` | Own format, [`schemas/pricing.schema.json`](../schemas/pricing.schema.json) | `check-jsonschema` | Websites, billing |
| Pirol "Company as Code" | (reserved) | [Pirol-ai/company-as-code](https://github.com/Pirol-ai/company-as-code) v0.4.0 | Not implemented; see [ADR 0006](adr/0006-defer-pirol-company-as-code.md) | - |

Every exporter can be turned off with `company.exports.<name>.enable`.
Consumers of `flakeModules.company` get all of this validation as
`checks.<system>.company-exports-valid`.
