# Architecture / архитектура

- **Official product boundary:** `scripts/install-official.sh` / PowerShell `-Action Install` download the current official OpenAI installer; they do not fork, recompile, patch or vendor Codex. Version policy is **latest official stable selected by the upstream script**; scripts do not select prerelease tags themselves.
- **Profile engine on Unix:** Python 3 stdlib, `scripts/homeport.py` (no pip dependencies).
- **Profile engine on Windows:** PowerShell 7 stdlib, `scripts/homeport.ps1` (no Python dependency).
- **Storage format 1:** `manifest.json` + `data/codex/...` and `data/agents/...`, with file size + SHA-256. Both implementations share a simple JSON schema. Metadata has no absolute source paths.
- **Backup:** create-only, private path, explicit allowlist, skip symlinks and private/internal files, hash all written files, verify before success.
- **Recovery:** load+verify everything, dry-run by default, create a local rollback for overwritten files, copy/replace incrementally, post-restore verification. No implicit deletions or authentication copying.
- **Logging:** line-oriented JSON (stdout; optional private `--audit-log`/`-AuditLog` with per-file entries) containing UTC timestamp, action, PASS/FAIL/DRY_RUN, path to the user's private backup when relevant, file counts, and failure explanation; never log file contents or credentials. Caller controls where logs are redirected, and should treat logs as private.
- **Public Git:** only generic source code, tests, docs and license. CI uses synthetic, isolated test profiles.

## Known portability limits

Cross-OS config files may contain absolute paths, external MCP executable names, environment variable conventions, shell hooks, sandbox differences, UI references and keyring settings. These require a post-restore review. External skill symlinks and system skill packages aren't copied. Codex Desktop's native installed version is a separate distribution responsibility. A successful hash check proves bytes were transported unchanged, **not** that Codex will load every skill or server correctly.
