# Security boundaries

[Русский](../ru/SECURITY.md) | [Overview](README.md)

1. No private exports, `auth.json`, tokens, session history, SQLite, credentials, personal logs, or executable Codex builds in the public repository, PRs, Issues or CI artifacts.
2. Snapshots can contain literal credentials in `config.toml` or `AGENTS.md`. Snapshots are **unencrypted**. Keep them in a private user-owned directory outside Git. SHA-256 detects modification but does not establish the trustworthiness of the source.
3. Restore verifies paths, size limits and checksums, defaults to dry-run and requires explicit apply. Existing target files are copied aside for rollback. Power failures, concurrent writes, or compromised input are not guaranteed recoverable.
4. Desktop state, login and third-party MCP installations are excluded. Review skills before executing them.
5. Tests use synthetic fixtures and read-only workflow permissions. Report vulnerabilities through private vulnerability reporting where available; never post real secrets publicly.

The technical threat model is maintained in [docs/SECURITY.md](../SECURITY.md).
