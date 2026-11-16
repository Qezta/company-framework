# Agent instructions

This repository describes the company as code with
[company-framework](https://github.com/Qezta/company-framework).

- Structured facts live in `company.nix`; prose lives in Markdown (`policies/`, `processes/docs/`, `decisions/`, `legal/`).
- Never hand-edit `exports/`. After changing `company.nix` or the Markdown it references, run `nix run .#update-exports`, `git add exports`, then `nix flake check -L`.
- Generated context about the company for agents: `exports/agents/AGENTS.md` and `exports/llms.txt`.
