# Security model / модель безопасности

## Boundary

This repository **never** stores personal Codex state. It contains only code, tests, documentation, and non-personal examples. Local snapshots are written only to a newly created, explicitly chosen path **outside a Git working tree**. Do not put them in public issue attachments, releases, CI artifacts, or cloud drives without encryption.

- Not backed up: `auth.json`, tokens/credential files, `history.jsonl`, sessions, SQLite and their WAL/SHM files, logs, binary caches and installers, `.git` contents, `.env` files and matching names in skill directories.
- Backed up **locally and unencrypted**: `config.toml`, `AGENTS.md`, skill/rule/prompt/memory files. These *may themselves* hold secrets, tokens in literal settings, internal hostnames, project names, or personal data. Automatic content-level secret detection cannot guarantee safety.
- `CODEX_HOME` may redirect the root; backup preserves content, not the original OS path. `CODEX_SQLITE_HOME` state is excluded.
- Symlinks are not exported and are refused in snapshot paths and restore destinations.
- Backup files are private by POSIX permissions (`0700` directory; `0600` files). On Windows, protection depends on the enclosing user-owned NTFS ACL. Never share backups with untrusted users.
- Hash validation is **corruption detection only**, not authentication against a malicious actor who can rewrite both the data and the manifest. Only restore backups from a trusted origin.
- A downloaded OpenAI script is still executable code. Installation is a separate explicit command, and the official script is fetched from `https://chatgpt.com/codex/install.sh` or `.ps1`. Inspect the script if you require review/signature verification. Network version validation and installer smoke test were not run here.
- Source control and the backup directory should have different access patterns. Never commit a private backup, even if `.gitignore` appears to protect it.

## Threat and rollback behavior

All snapshot entries are checked against a small allowlist. Rooted paths, traversal, path separators inappropriate to the platform, links, and disallowed private names are blocked. Existing paths are copied to a rollback directory before writing. Failure can leave manually recoverable files; rollback is best-effort, not a guarantee against power loss, disk corruption, concurrent writes, or antivirus interference. Close Codex/Desktop before applying a snapshot.

## Supported vs excluded restoration

Supported: user config, profile `*.config.toml`, instructions, globally installed skills stored as regular files, rules, prompts, memory files (when present). Excluded: login, keychain, active session continuity, Desktop app internals, per-project source code, third-party executables and the complete dependency graph of custom skills.

For especially sensitive environments, prefer an encrypted OS-level backup system rather than this plaintext portability tool.


## Additional supply-chain and public-push safeguards (v0.0.1)

The `scripts/check-public-tree.py` guard inspects Git-tracked files and common token patterns. It has false negatives and does **not** scan old remote Git history, LFS, artifacts or CI secrets. Review `git log --stat`, `git diff --cached`, and external scanners if available before any remote push. Do not attach private logs to reports. Homeport copies skill scripts as data without executing them, but later launching Codex could cause execution of untrusted skill/MCP code. Review before use.

Default limits: 5000 files / 25 MiB per file / 250 MiB total; manifest max 4 MiB. To avoid source-to-target mutation races, snapshot contents are staged in a private rollback folder before changes. A source file may still change while being copied and this results in a fail-closed hash mismatch. PowerShell and Python both need real-platform acceptance before claiming identical security posture. Windows ACLs remain dependent on the current user's filesystem; do not treat standard PowerShell directory creation as guaranteed strict isolation.

Homeport rejects writing private backup and audit files within the live Codex/agents profile and refuses symlinked backup ancestors; do not bypass these checks.
