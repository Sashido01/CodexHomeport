# Codex Homeport repository instructions

- Use the official OpenAI Codex installer/runtime. Never distribute a modified Codex executable or implement an alternative runtime.
- No real user data, auth, tokens, session history, logs, SQLite or private snapshots in the repository.
- Changes touching backup/restore must have fail-closed tests for paths, hashes, dry-run, symlinks, and rollback behavior.
- Preserve the caller's `config.toml` and AGENTS settings exactly as backed up; do not impose a model, provider, key or sandbox setting.
- Prefer native OS capabilities, no external dependencies for the profile engine, no hidden background services.
- Maintain docs/RESEARCH.md, docs/VALIDATION.md, CHANGELOG.md with observed evidence. Distinguish tests from real device acceptance.
- Use local Git commits. Do not push, merge or publish without explicit authorization. Do not touch unrelated projects.
