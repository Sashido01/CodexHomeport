# Architecture / архитектура

- **Official product boundary:** `scripts/install-official.sh` / PowerShell `-Action Install` download the current official OpenAI installer; they do not fork, recompile, patch or vendor Codex. Version policy is **latest official stable selected by the upstream script**; scripts do not select prerelease tags themselves.
- **Profile engine on Unix:** Python 3 stdlib, `scripts/homeport.py` (no pip dependencies).
- **Profile engine on Windows:** PowerShell 7 stdlib, `scripts/homeport.ps1` (no Python dependency).
- **Storage format 1:** `manifest.json` + `data/codex/...` and `data/agents/...`, with file size + SHA-256. Both implementations share a simple JSON schema. Metadata has no absolute source paths.
- **Backup:** create-only, private path, explicit allowlist, skip symlinks and private/internal files, hash all written files, verify before success.
- **Recovery:** load+verify everything, dry-run by default, create a local rollback for overwritten files, copy/replace incrementally, post-restore verification. No implicit deletions or authentication copying.
- **Logging:** line-oriented JSON (stdout; optional private `--audit-log`/`-AuditLog` with per-file entries) containing UTC timestamp, action, PASS/FAIL/DRY_RUN, path to the user's private backup when relevant, file counts, and failure explanation; never log file contents or credentials. Caller controls where logs are redirected, and should treat logs as private.
- **Public Git:** only generic source code, tests, docs and license. CI uses synthetic, isolated test profiles.
- **Customization guidance:** generic model-selection, allowance, `AGENTS.md`, skill and MCP advice is documentation-only and opt-in. It does not install skills, register servers, or edit the user's configuration.

## Known portability limits

Cross-OS config files may contain absolute paths, external MCP executable names, environment variable conventions, shell hooks, sandbox differences, UI references and keyring settings. These require a post-restore review. External skill symlinks and system skill packages aren't copied. Codex Desktop's native installed version is a separate distribution responsibility. A successful hash check proves bytes were transported unchanged, **not** that Codex will load every skill or server correctly.


## Sequence / data-plane versus control-plane

- **Control plane (public)**: source, JSON manifest schema, docs and harmless templates. `Homeport.cmd` is the only Windows menu, no extra daemon or browser runtime.
- **Data plane (private)**: actual local `~/.codex` allowlisted files, private snapshot, content hashes, rollback staging, private JSONL. Never copied into Git by Homeport.
- **Install plane (official)**: independent upstream OpenAI CLI installer, invoked only explicitly. No binary distributed here; Desktop install/update continues in its official application channel.
- **Publish plane (native Git/GitHub)**: local commits + annotated tags, CI and GitHub `gh`/Git publication performed by the owner. Profiles never cross the publication plane.

Conservative limits: up to 5000 files; each at most 25 MiB, sum at most 250 MiB, manifest at most 4 MiB. This is deliberate protection against pathological input, not a promise to preserve arbitrarily huge custom skills. Hash checks detect corruption, not malicious rewrites of data plus manifest.

## Manual customization boundary

Homeport intentionally has no profile-import/merge engine. Users can compare generic templates with existing settings and make their own changes using native Codex configuration and MCP commands. The backup engine can preserve selected global files; it does not provision project policy, external tools, authentication or server authorization. A configuration value is not evidence of the active chat model or account entitlement.


## Prepared profile bootstrap (0.0.6)

The public setup layer is separate from private snapshot recovery. `scripts/bootstrap.ps1` and `scripts/bootstrap.py` create only missing global `AGENTS.md`, `config.toml` and included original text-only skills under `CODEX_HOME`. A dry-run JSONL plan is the default; writing needs explicit apply. Existing files, login/session state, selected model, approval/sandbox and personal MCP entries are never overwritten. Optional official CLI install and Windows Store Desktop install are separate, explicit operations. Linux Desktop preview uses the OS-native OpenAI package. Existing recovery schema and conservative limits remain unchanged.
