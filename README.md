<div id="top">
    <div align="center">
        <img alt='An abstract image of a donut-like object' title='Qezta' height=250 width=250 src='https://qezta.com/qezta.gif' />
        <h1 align='center'>company-framework</h1>
        <strong>Typed Nix description of a company that compiles to community-standard formats</strong>
    </div>

</div>

______________________________________________________________________

<div align='center'>
    <a href="https://github.com/Qezta/company-framework/stargazers">
        <img src="https://img.shields.io/github/stars/Qezta/company-framework?&style=for-the-badge&logoColor=white&color=purple&logo=starship" alt="stars"/>
    </a>
    <a href="https://github.com/Qezta/company-framework/">
        <img src="https://img.shields.io/github/repo-size/Qezta/company-framework?&style=for-the-badge&logoColor=white&color=purple&logo=github" alt="size"/>
    </a>
    <a href="https://github.com/Qezta/company-framework/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/Qezta/company-framework?&style=for-the-badge&logoColor=white&color=purple&logo=unlicense" alt="license"/>
    </a>
    <a href="https://github.com/nixos/nixpkgs">
        <img src="https://img.shields.io/badge/Nixpkgs-unstable-blue.svg?style=for-the-badge&logo=NixOS&logoColor=white&color=purple" alt="nixpkgs"/>
    </a>
    <img src="https://img.shields.io/github/languages/top/Qezta/company-framework?style=for-the-badge&color=purple" alt="repo-top-language"/>
</div>

______________________________________________________________________

<div align='center'>
    <a href="https://github.com/Qezta/company-framework/actions/workflows/ci.yml">
        <img src="https://github.com/Qezta/company-framework/actions/workflows/ci.yml/badge.svg" alt="ci"/>
    </a>
</div>

______________________________________________________________________

## Contents

- [Overview](#overview)
- [Quick start](#quick-start)
- [Installation](#installation)
- [Usage](#usage)
- [How it works](#how-it-works)
- [Configuration](#configuration)
- [Development](#development)
- [License](#license)

______________________________________________________________________

## Overview

> **Status: experimental (0.x).** Options and export formats may change between minor versions.

A typed, Nix-native description of a company — its entity, people, roles,
domains and systems — that compiles to formats existing tools already read.

```mermaid
flowchart LR
  subgraph source["Source (typed)"]
    nix["Nix modules<br/>company.nix"]
    md["Markdown<br/>policies · ADRs · drafts"]
  end
  subgraph interchange["Interchange (standard formats)"]
    spec["spec.json"]
    bs["Backstage catalog"]
    scim["SCIM 2.0"]
    co["CODEOWNERS"]
    opa["OPA data + Rego"]
    sw["Serverless Workflow<br/>+ Mermaid"]
    slo["OpenSLO"]
    agents["AGENTS.md · llms.txt"]
    proj["public projection"]
  end
  subgraph execution["Execution (any tool)"]
    portal["developer portals"]
    idp["identity providers"]
    gh["GitHub"]
    gate["policy gates"]
    wf["workflow engines"]
    slot["SLO tooling"]
    ai["AI agents"]
    iac["infrastructure as code"]
  end
  nix --> spec & bs & scim & co & opa & sw & slo & agents & proj
  md --> agents
  bs --> portal
  scim --> idp
  co --> gh
  opa --> gate
  sw --> wf
  slo --> slot
  agents --> ai
  proj --> iac
```

- **Humans read it → Markdown.** Policies, ADRs, SOPs.
- **Machines check it → Nix.** Roles, people, ownership, systems.
- **Tools consume it → their native format.** No tool ever has to read Nix.
- **Generated exports are committed** and CI fails on drift, so the data is never trapped in Nix.

## Quick start

```sh
mkdir my-company && cd my-company
nix flake init -t github:Qezta/company-framework
git init && git add -A
nix flake check
```

## Installation

Add the flake as an input:

```nix
inputs.company-framework.url = "github:Qezta/company-framework";
```

Requires Nix with flakes enabled. Evaluation is pure: no network access and no
import-from-derivation.

## Usage

### With flake-parts

```nix
{
  imports = [ inputs.company-framework.flakeModules.company ];
  company.modules = [ ./company.nix ];
  # company.exportsDir = "exports";   # default
}
```

This adds:

| Output | What it is |
| --- | --- |
| `packages.<system>.exports` | The full export tree |
| `packages.<system>.spec` | `spec.json` on its own |
| `apps.<system>.update-exports` | Copies the export tree into `exportsDir` |
| `checks.<system>.company-exports-drift` | Fails if committed exports are stale |
| `checks.<system>.company-exports-valid` | Validates every export against its standard and runs the OPA policies |

### Without flake-parts

The core depends only on nixpkgs `lib`:

```nix
let
  company = inputs.company-framework.lib;
  eval = company.evalCompany { modules = [ ./company.nix ]; };
in
  company.materialize { inherit pkgs; files = company.checkedFiles eval; }
```

`checkedFiles` throws with every failed assertion listed;
`failedAssertions eval.config` returns them as a list instead.

## How it works

```mermaid
flowchart LR
  mods["your company modules"] --> eval["lib.evalCompany"]
  eval --> ok{"all assertions hold?"}
  ok -- no --> fail["evaluation fails,<br/>listing every message"]
  ok -- yes --> files["exporters fill<br/>output.files"]
  files --> mat["lib.materialize<br/>(pure-Nix JSON/YAML)"]
  mat --> valid["company-exports-valid<br/>schemas · oslo · OPA"]
  mat --> drift["company-exports-drift<br/>vs committed exports/"]
```

Every reference, cycle, date and identity rule is checked before anything is
written, and every export is validated against its own standard.

## Configuration

A company is one module setting `company.*`. The full reference is
[docs/options.md](docs/options.md); [docs/standards.md](docs/standards.md)
maps every export to its standard. See
[`examples/acme/acme.nix`](examples/acme/acme.nix) for a fictional company
that uses every option.

| Option | Holds |
| --- | --- |
| `company.entity` | Names, jurisdiction, public registration ids, domains, contacts, links, brand |
| `company.people.<id>` | Name, email, GitHub login, roles, status, start/end dates |
| `company.roles.<id>` | Description, parent role, GitHub team + permission, responsibilities |
| `company.domains.<id>` | Description, owning role |
| `company.systems.<id>` | Type, lifecycle, domain, owner, repo, CODEOWNERS rules, dependencies, links |
| `company.policies.<id>` | Title, owner, Markdown doc, review cadence, machine rules for OPA |
| `company.processes.<id>` | Owner, trigger, inputs, and a DAG of steps (task, approval, automated, decision) |
| `company.reliability.slos.<id>` | System, indicator, target, window, metric source |
| `company.pricing` | Currency and plans (prices in minor units) |
| `company.decisionsDir` | MADR decision records, read into `company.decisions` |
| `company.root` | Directory Markdown paths are relative to |
| `company.asOf` | Reference date for date-relative checks (evaluation cannot read the clock) |
| `company.exports.<name>.enable` | Toggle each exporter |

Every reference is checked (roles, parents, owners, domains, dependencies,
CODEOWNERS), the role tree must be acyclic, dates must be real calendar dates,
GitHub-mapped roles need a `githubUser`, and team slugs must be unique.

## Development

```sh
nix develop                 # dev shell with every tool
nix fmt                     # format
update-all                  # regenerate acme + template exports and docs/options.md (dev shell)
nix flake check -L          # all checks
```

See [AGENTS.md](AGENTS.md) for contribution rules and
[docs/adr](docs/adr) for design decisions.

## License

[MIT](LICENSE)

<div align="right">

[![][back-to-top]](#top)

</div>

[back-to-top]: https://img.shields.io/badge/-BACK_TO_TOP-151515?style=flat-square&color=purple
