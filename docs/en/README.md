# Codex Homeport — English documentation

[Русский](../ru/README.md) · [Getting started](GETTING_STARTED.md) · [Customization](CUSTOMIZATION.md) · [Security](SECURITY.md) · [Maintenance](MAINTENANCE.md) · [CI policy](CI_POLICY.md) · [Contributing](CONTRIBUTING.md)

Codex Homeport is an independent open-source companion for using the official Codex CLI and safely recovering selected user configuration. It is **not** an OpenAI product, does not fork Codex, does not change sign-in or install an alternative runtime.

It supports reading status, opt-in official CLI installation, local private backups, SHA-256 manifest verification, non-writing restore plans, explicit apply and rollback snapshots. Windows uses PowerShell 7; Linux/macOS uses Python 3.9+. Project paths and backup locations are chosen by users.

**Not included:** account login, secrets, chat sessions/history, SQLite databases, Codex Desktop state, external MCP installations or separate project repositories. Snapshots are not encrypted and must never be committed or attached to public issues.

The project previously passed synthetic profile checks on Windows and Linux in v0.0.3; that does **not** prove live user profile or Desktop recovery. Evidence and limits are in [validation history](../VALIDATION.md). The current in-development version is in [VERSION](../../VERSION).

Licensed under [MIT](../../LICENSE). Codex and OpenAI are trademarks of OpenAI.
