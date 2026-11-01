# Validation evidence — Homeport v0.0.1 (2026-11-01)

## Confirmed local isolated checks

Command: `python -m unittest discover -s tests -v` (Linux, Python 3.13). **17/17 PASS** on a synthetic fake home directory; no current Codex profile read or written. Coverage: backup manifest and allowlist, exclusions of auth/sessions, verify and recovery dry-run/apply, rollback snapshot, tampering/traversal checks, Git worktree backup refusal, symlink paths, repeated snapshots, private filename exclusion, duplicate rows, private JSONL event rows, custom `CODEX_HOME`, version, manifest size/hash invalid types, portable collision rejection, oversized backup cleanup, and refusal of backup/audit files inside a live profile.

Command: `python scripts/check-public-tree.py` with staged source tracked in Git. PASS at release creation; heuristic names and tokens only, not a formal proof of secret absence. `python -m py_compile scripts/homeport.py scripts/check-public-tree.py` and `git diff --check` also verified at release packaging.

## NOT_VERIFIED (not an implementation claim)

- Genuine Windows PowerShell 7 runtime, ACL behavior, Windows installer execution, and real GUI double-click.
- GitHub Actions remote runner outcomes, remote branch protections, publication of this source/tag to the already existing public repository and public tag existence.
- Native official Codex installer execution/upgrade, ChatGPT sign-in, Codex Desktop session restore, MCP reconnect, physical device behavior.
- Real existing user profile migration on Windows/Ubuntu and cross-OS path rewriting.

## Scope and stop condition

This package is a source-complete `v0.0.1` candidate, **not** a proven ready-to-restore-the-entire-desktop product. A successful native Windows isolated run and actual GitHub publication/CI evidence are required before calling the overall requested delivery COMPLETE. Those external steps are the only remaining acceptance gaps; do not create endless optional tasks.
