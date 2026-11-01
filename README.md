# Codex Homeport

**Official Codex CLI, conservative private configuration recovery.**

Codex Homeport is an **independent**, MIT-licensed companion. It invokes official OpenAI installation methods; it does not fork Codex, change authentication, distribute credentials, or restore Codex Desktop sessions.

## Choose your documentation language

**[English](docs/en/README.md)** · **[Русский](docs/ru/README.md)**

Separate English and Russian guides cover installation, backup, restoration, security, contributions, GitHub Actions and maintenance. Technical decisions and historical test evidence are in [docs](docs).

Optional templates and guidance for model selection, `AGENTS.md`, skills and MCP are in the [customization guide](docs/en/CUSTOMIZATION.md) ([русская версия](docs/ru/CUSTOMIZATION.md)). No template is applied automatically.

## Capabilities

| Component | Behavior |
| --- | --- |
| Official CLI | Detect, with opt-in official install/update |
| Private snapshots | Selected configuration, instructions, skills and rules only |
| Verified recovery | Allowlisted files, manifest, SHA-256, dry-run, explicit apply and rollback |
| Windows | PowerShell 7 and `Homeport.cmd` menu |
| Linux/macOS | Python 3.9+ and native installer entry point |
| CI | Isolated Windows/Linux tests and no private profiles |

Quick read-only check (Windows): `pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Status`. Linux/macOS: `python3 scripts/homeport.py status`. Before restoring, read [English guide](docs/en/GETTING_STARTED.md) or [русское руководство](docs/ru/GETTING_STARTED.md).

**Never upload snapshots to Git or a public issue.** Homeport does not preserve credentials, conversations, installed MCP servers or native Desktop state.

The source microversion is in [VERSION](VERSION). Historical test evidence and known gaps are in [VALIDATION](docs/VALIDATION.md). **Unofficial: not an OpenAI product.** [MIT license](LICENSE).
