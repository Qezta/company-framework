# Backstage catalog entity schemas

| Field | Value |
| --- | --- |
| Source | https://github.com/backstage/backstage/tree/v1.56.5/packages/catalog-model/src/schema |
| Tag | `v1.56.5` |
| Retrieved | 2026-11-16 |
| License | Apache-2.0 (`LICENSES/Apache-2.0.txt`) |
| Files | `Entity`, `EntityEnvelope`, `EntityMeta`, `shared/common` (as `common`), `kinds/{User,Group,System,Component,Domain,Resource}.v1alpha1` |

Unmodified. The schemas reference each other by bare `$id` (`Entity`,
`common#relation`); the `backstage-catalog` check rewrites those to file
references in a temporary copy before validating, so the files here stay
byte-identical to upstream.
