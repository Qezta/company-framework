# Schemas written for this project

These are authored here (MIT), because no official JSON Schema exists.

| Schema | Based on |
| --- | --- |
| `company.schema.json` | The framework's own `spec.json` format. |
| `pricing.schema.json` | The framework's own `pricing.json` format (the `pricing` definition of `company.schema.json`). |
| `scim.schema.json` | [RFC 7643](https://www.rfc-editor.org/rfc/rfc7643) §4.1 (User), §4.2 (Group), §8.7.1 (schema URNs) and [RFC 7644](https://www.rfc-editor.org/rfc/rfc7644) §3.4.2 (ListResponse), restricted to the attributes the SCIM exporter emits. Retrieved 2026-11-16. |

OpenSLO also publishes no JSON Schema; OpenSLO exports are validated with the
reference CLI instead (`pkgs/oslo.nix`, OpenSLO/oslo `v0.13.0`, Apache-2.0).
