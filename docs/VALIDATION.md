# Validation report / отчёт о проверке

**Scope**: local synthetic profiles; no Codex installation, credentials, network, or machine state modified.

Test command: `python3 -m unittest discover -s tests -v`

At build: **11/11 PASS** on the available Linux container:

1. Selective backup of config/AGENTS/skills with exclusions and integrity verification.
2. Dry-run unchanged source, explicit apply, post-restore hashes, preserved rollback copy and unrelated files.
3. Tamper detection / fail closed.
4. Manifest traversal rejection / fail closed.
5. Reject backup inside Git worktree.
6. Reject symlink source and destination.
7. Reject overwrite of an existing snapshot.
8. Explicit `CODEX_HOME` path override.
9. Exclude `.env.production` and private `.pem` files.
10. Reject duplicate entries in a manifest.
11. Private JSONL audit trail with per-file details and no file-content disclosure.

**Not verified:** Windows PowerShell runtime integration, Windows ACL behavior, symlink/reparse-point corner cases on NTFS, Linux/macOS official installer actual download, Windows official installer actual download, GUI/desktop app state recovery, cross-OS absolute-path translation, installed MCP/skills execution, live authenticated Codex session.

**Status:** Linux profile mechanism VERIFIED IN ISOLATION; Windows mechanism and upstream installation NOT_VERIFIED; full user environment migration NOT_VERIFIED.
